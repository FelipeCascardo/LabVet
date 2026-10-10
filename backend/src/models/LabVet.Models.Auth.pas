unit LabVet.Models.Auth;

interface

uses System.JSON;

type
  TLoginInput = class
  public
    Email: string;
    Password: string;
    class function FromJSON(AJson: TJSONObject): TLoginInput; static;
  end;

  TAuthResponse = class
  public
    AccessToken: string;
    RefreshToken: string;
    ExpiresIn: Integer;
    function ToJSON: TJSONObject;
  end;

implementation

uses System.SysUtils;

function JsonText(AJson: TJSONObject; const AName: string): string;
var
  LValue: TJSONValue;
begin
  LValue := AJson.GetValue(AName);
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result := LValue.Value
  else
    Result := '';
end;

class function TLoginInput.FromJSON(AJson: TJSONObject): TLoginInput;
begin
  if not Assigned(AJson) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  Result := TLoginInput.Create;
  Result.Email := JsonText(AJson, 'email');
  Result.Password := JsonText(AJson, 'senha');
end;

function TAuthResponse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('accessToken', AccessToken);
  Result.AddPair('expiraEm', TJSONNumber.Create(ExpiresIn));
end;

end.
