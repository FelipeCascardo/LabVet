unit LabVet.Middlewares.Auth;

interface

uses Horse;

procedure Register;
function CurrentUserId(ARequest: THorseRequest): Int64;

implementation

uses
  System.JSON, System.SysUtils,
  Horse.Commons, Horse.Exception, Horse.JWT, JOSE.Core.JWT,
  LabVet.Providers.Config, LabVet.Repositories.Session;

function IsPublicRoute(const APath: string): Boolean;
begin
  Result := (APath = '/api/v1/health') or (APath = '/api/v1/auth/login') or
    (APath = '/api/v1/auth/refresh') or (APath = '/api/v1/auth/logout') or
    (APath = '/api/v1/setup/primeiro-usuario');
end;

function IntegerClaim(AClaims: TJWTClaims; const AName: string; out AValue: Int64): Boolean;
var
  LValue: TJSONValue;
begin
  LValue := AClaims.JSON.GetValue(AName);
  Result := Assigned(LValue) and TryStrToInt64(LValue.Value, AValue);
end;

function CurrentUserId(ARequest: THorseRequest): Int64;
var
  LClaims: TJWTClaims;
begin
  LClaims := ARequest.Session<TJWTClaims>;
  if (not Assigned(LClaims)) or not TryStrToInt64(LClaims.Subject, Result) or
    (Result <= 0) then
    raise EHorseException.New.Status(THTTPStatus.Unauthorized).Error('Token inválido.');
end;

procedure ValidateSession(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LClaims: TJWTClaims;
  LUserId, LSessionId, LVersion: Int64;
  LRepository: TSessionRepository;
  LSession: TUserSession;
begin
  if IsPublicRoute(ARequest.PathInfo) then
  begin
    ANext();
    Exit;
  end;
  LClaims := ARequest.Session<TJWTClaims>;
  if (not Assigned(LClaims)) or not TryStrToInt64(LClaims.Subject, LUserId) or
    not IntegerClaim(LClaims, 'sid', LSessionId) or not IntegerClaim(LClaims, 'sv', LVersion) or
    not SameText(LClaims.Issuer, TLabVetConfig.GetValue('LABVET_JWT_ISSUER', 'labvet-api')) then
    raise EHorseException.New.Status(THTTPStatus.Unauthorized).Error('Token inválido.');
  LRepository := TSessionRepository.Create;
  try
    LSession := LRepository.FindById(LSessionId);
    try
      if (not Assigned(LSession)) or (LSession.UserId <> LUserId) or
        (LSession.SecurityVersion <> LVersion) or (LSession.RevokedAt <> 0) or
        (LSession.ExpiresAt <= Now) then
        raise EHorseException.New.Status(THTTPStatus.Unauthorized).Error('Sessão expirada.');
    finally
      LSession.Free;
    end;
  finally
    LRepository.Free;
  end;
  ANext();
end;

procedure Register;
var
  LSecret: string;
begin
  LSecret := TLabVetConfig.GetValue('LABVET_JWT_SECRET');
  if Length(LSecret) < 32 then
    raise EInvalidOp.Create('Defina LABVET_JWT_SECRET com ao menos 32 caracteres.');
  THorse.Use(HorseJWT(LSecret,
    THorseJWTConfig.New
      .SkipRoutes(['/api/v1/health', '/api/v1/auth/login', '/api/v1/auth/refresh', '/api/v1/auth/logout', '/api/v1/setup/primeiro-usuario'])
      .SessionClass(TJWTClaims)
      .IsRequiredSubject(True)
      .IsRequiredIssuedAt(True)
      .IsRequiredExpirationTime(True)
      .IsRequireAudience(True)
      .ExpectedAudience([TLabVetConfig.GetValue('LABVET_JWT_AUDIENCE', 'labvet-web')])));
  THorse.Use(ValidateSession);
end;

end.
