unit LabVet.Services.Auth;

interface

uses System.SysUtils, LabVet.Models.Auth;

type
  EAuthenticationFailed = class(Exception);

  TAuthService = class
  private
    function NewRefreshToken: string;
    function HashRefreshToken(const AToken: string): string;
    function NewAccessToken(AUserId, ASessionId: Int64; ASecurityVersion: Integer): string;
  public
    function Login(AInput: TLoginInput): TAuthResponse;
    function Refresh(const ARefreshToken: string): TAuthResponse;
    procedure Logout(const ARefreshToken: string);
  end;

implementation

uses
  System.DateUtils, System.Hash, System.SysUtils,
  JOSE.Core.Builder, JOSE.Core.JWT,
  LabVet.Models.User, LabVet.Providers.Config,
  LabVet.Repositories.Session, LabVet.Repositories.User,
  LabVet.Services.Audit, LabVet.Services.Password;

const
  ACCESS_TOKEN_MINUTES = 30;
  REFRESH_TOKEN_DAYS = 30;

function TAuthService.NewRefreshToken: string;
var
  LFirst, LSecond: TGUID;
begin
  CreateGUID(LFirst);
  CreateGUID(LSecond);
  Result := GUIDToString(LFirst).Replace('{', '').Replace('}', '').Replace('-', '') +
    GUIDToString(LSecond).Replace('{', '').Replace('}', '').Replace('-', '');
end;

function TAuthService.HashRefreshToken(const AToken: string): string;
begin
  Result := THashSHA2.GetHashString(AToken);
end;

function TAuthService.NewAccessToken(AUserId, ASessionId: Int64;
  ASecurityVersion: Integer): string;
var
  LJwt: TJWT;
begin
  LJwt := TJWT.Create;
  try
    LJwt.Claims.Issuer := TLabVetConfig.GetValue('LABVET_JWT_ISSUER', 'labvet-api');
    LJwt.Claims.Audience := TLabVetConfig.GetValue('LABVET_JWT_AUDIENCE', 'labvet-web');
    LJwt.Claims.Subject := AUserId.ToString;
    LJwt.Claims.IssuedAt := Now;
    LJwt.Claims.Expiration := IncMinute(Now, ACCESS_TOKEN_MINUTES);
    LJwt.Claims.SetClaimOfType<Int64>('sid', ASessionId);
    LJwt.Claims.SetClaimOfType<Integer>('sv', ASecurityVersion);
    Result := TJOSE.SHA256CompactToken(TLabVetConfig.GetValue('LABVET_JWT_SECRET'), LJwt);
  finally
    LJwt.Free;
  end;
end;

function TAuthService.Login(AInput: TLoginInput): TAuthResponse;
var
  LUsers: TUserRepository;
  LSessions: TSessionRepository;
  LUser: TAppUser;
  LSession: TUserSession;
  LRefresh: string;
begin
  if AInput.Email.Trim.IsEmpty or AInput.Password.IsEmpty then
    raise EAuthenticationFailed.Create('E-mail ou senha inválidos.');
  LUsers := TUserRepository.Create;
  try
    LUser := LUsers.FindByEmail(AInput.Email.Trim);
    try
      if (not Assigned(LUser)) or (not LUser.IsActive) or
        (not TPasswordService.Verify(AInput.Password, LUser.PasswordHash)) then
        raise EAuthenticationFailed.Create('E-mail ou senha inválidos.');
      LRefresh := NewRefreshToken;
      LSessions := TSessionRepository.Create;
      try
        LSession := LSessions.CreateSession(LUser.Id, HashRefreshToken(LRefresh),
          IncDay(Now, REFRESH_TOKEN_DAYS), LUser.SecurityVersion);
        try
          Result := TAuthResponse.Create;
          Result.RefreshToken := LRefresh;
          Result.AccessToken := NewAccessToken(LUser.Id, LSession.Id, LUser.SecurityVersion);
          Result.ExpiresIn := ACCESS_TOKEN_MINUTES * 60;
          TAuditService.RegisterEvent(LUser.Id, 'auth.login', 'user_session', LSession.Id.ToString, '');
        finally
          LSession.Free;
        end;
      finally
        LSessions.Free;
      end;
    finally
      LUser.Free;
    end;
  finally
    LUsers.Free;
  end;
end;

function TAuthService.Refresh(const ARefreshToken: string): TAuthResponse;
var
  LSessions: TSessionRepository;
  LUsers: TUserRepository;
  LSession: TUserSession;
  LUser: TAppUser;
  LNewRefresh: string;
begin
  if ARefreshToken.IsEmpty then raise EAuthenticationFailed.Create('Sessão expirada.');
  LSessions := TSessionRepository.Create;
  try
    LSession := LSessions.FindByRefreshHash(HashRefreshToken(ARefreshToken));
    try
      if (not Assigned(LSession)) or (LSession.ExpiresAt <= Now) then
        raise EAuthenticationFailed.Create('Sessão expirada.');
      LUsers := TUserRepository.Create;
      try
        LUser := LUsers.FindById(LSession.UserId);
        try
          if (not Assigned(LUser)) or (not LUser.IsActive) or
            (LUser.SecurityVersion <> LSession.SecurityVersion) then
          begin
            LSessions.Revoke(LSession.Id);
            raise EAuthenticationFailed.Create('Sessão expirada.');
          end;
          LNewRefresh := NewRefreshToken;
          LSessions.Rotate(LSession.Id, HashRefreshToken(LNewRefresh), IncDay(Now, REFRESH_TOKEN_DAYS));
          Result := TAuthResponse.Create;
          Result.RefreshToken := LNewRefresh;
          Result.AccessToken := NewAccessToken(LUser.Id, LSession.Id, LUser.SecurityVersion);
          Result.ExpiresIn := ACCESS_TOKEN_MINUTES * 60;
          TAuditService.RegisterEvent(LUser.Id, 'auth.refresh', 'user_session', LSession.Id.ToString, '');
        finally
          LUser.Free;
        end;
      finally
        LUsers.Free;
      end;
    finally
      LSession.Free;
    end;
  finally
    LSessions.Free;
  end;
end;

procedure TAuthService.Logout(const ARefreshToken: string);
var
  LSessions: TSessionRepository;
  LSession: TUserSession;
begin
  if ARefreshToken.IsEmpty then Exit;
  LSessions := TSessionRepository.Create;
  try
    LSession := LSessions.FindByRefreshHash(HashRefreshToken(ARefreshToken));
    try
      if Assigned(LSession) then
      begin
        LSessions.Revoke(LSession.Id);
        TAuditService.RegisterEvent(LSession.UserId, 'auth.logout', 'user_session', LSession.Id.ToString, '');
      end;
    finally
      LSession.Free;
    end;
  finally
    LSessions.Free;
  end;
end;

end.
