unit LabVet.Controllers.Auth;

interface

procedure Register;

implementation

uses
  System.JSON, System.SysUtils,
  Horse, Horse.Commons, Horse.Core.Cookie, Horse.Exception,
  LabVet.Models.Auth, LabVet.Providers.Config, LabVet.Services.Auth;

const REFRESH_MAX_AGE = 30 * 24 * 60 * 60;

function RefreshCookieName: string;
begin
  Result := TLabVetConfig.GetValue('LABVET_REFRESH_COOKIE_NAME', 'labvetRefresh');
end;

function RequestJSON(ARequest: THorseRequest): TJSONObject;
var LValue: TJSONValue;
begin
  LValue := TJSONObject.ParseJSONValue(ARequest.Body);
  if not (LValue is TJSONObject) then
  begin
    LValue.Free;
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  end;
  Result := TJSONObject(LValue);
end;

procedure SendJSON(AResponse: THorseResponse; AJson: TJSONValue);
begin
  try AResponse.ContentType('application/json; charset=utf-8').Send(AJson.ToJSON); finally AJson.Free; end;
end;

procedure SetRefreshCookie(AResponse: THorseResponse; const AToken: string);
begin
  AResponse.Cookie(RefreshCookieName, AToken)
    .Path('/api/v1/auth').HttpOnly(True)
    .Secure(SameText(TLabVetConfig.GetValue('LABVET_COOKIE_SECURE', 'false'), 'true'))
    .SameSite(ssStrict).MaxAge(REFRESH_MAX_AGE);
end;

procedure ClearRefreshCookie(AResponse: THorseResponse);
begin
  AResponse.Cookie(RefreshCookieName, '').Path('/api/v1/auth').HttpOnly(True)
    .Secure(SameText(TLabVetConfig.GetValue('LABVET_COOKIE_SECURE', 'false'), 'true'))
    .SameSite(ssStrict).MaxAge(0);
end;

procedure Login(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var LJson: TJSONObject; LInput: TLoginInput; LService: TAuthService; LResult: TAuthResponse;
begin
  try
    LJson := RequestJSON(ARequest);
    try
      LInput := TLoginInput.FromJSON(LJson);
      try
        LService := TAuthService.Create;
        try
          LResult := LService.Login(LInput);
          try SetRefreshCookie(AResponse, LResult.RefreshToken); SendJSON(AResponse, LResult.ToJSON); finally LResult.Free; end;
        finally LService.Free; end;
      finally LInput.Free; end;
    finally LJson.Free; end;
  except
    on E: EAuthenticationFailed do raise EHorseException.New.Status(THTTPStatus.Unauthorized).Error(E.Message);
    on E: EArgumentException do raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(E.Message);
  end;
end;

procedure Refresh(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var LService: TAuthService; LResult: TAuthResponse;
begin
  try
    LService := TAuthService.Create;
    try
      LResult := LService.Refresh(ARequest.Cookie[RefreshCookieName]);
      try SetRefreshCookie(AResponse, LResult.RefreshToken); SendJSON(AResponse, LResult.ToJSON); finally LResult.Free; end;
    finally LService.Free; end;
  except
    on E: EAuthenticationFailed do begin ClearRefreshCookie(AResponse); raise EHorseException.New.Status(THTTPStatus.Unauthorized).Error(E.Message); end;
  end;
end;

procedure Logout(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var LService: TAuthService;
begin
  LService := TAuthService.Create;
  try LService.Logout(ARequest.Cookie[RefreshCookieName]); ClearRefreshCookie(AResponse); AResponse.Status(THTTPStatus.NoContent).Send(''); finally LService.Free; end;
end;

procedure Register;
begin
  THorse.Post('/api/v1/auth/login', Login);
  THorse.Post('/api/v1/auth/refresh', Refresh);
  THorse.Post('/api/v1/auth/logout', Logout);
end;

end.
