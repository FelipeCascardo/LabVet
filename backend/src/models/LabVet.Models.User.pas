unit LabVet.Models.User;

interface

uses System.JSON;

type
  TUserInput = class
  private
    FFullName: string;
    FEmail: string;
    FPassword: string;
  public
    class function FromJSON(AJson: TJSONObject): TUserInput; static;
    property FullName: string read FFullName write FFullName;
    property Email: string read FEmail write FEmail;
    property Password: string read FPassword write FPassword;
  end;

  TAppUser = class
  public
    Id: Int64;
    FullName: string;
    Email: string;
    PasswordHash: string;
    SecurityVersion: Integer;
    CreatedAt: TDateTime;
    UpdatedAt: TDateTime;
    IsActive: Boolean;
    function ToJSON: TJSONObject;
  end;

implementation

uses System.DateUtils, System.SysUtils;

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

class function TUserInput.FromJSON(AJson: TJSONObject): TUserInput;
begin
  if not Assigned(AJson) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  Result := TUserInput.Create;
  Result.FullName := JsonText(AJson, 'nome');
  Result.Email := JsonText(AJson, 'email');
  Result.Password := JsonText(AJson, 'senha');
end;

function TAppUser.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(Id));
  Result.AddPair('nome', FullName);
  Result.AddPair('email', Email);
  Result.AddPair('ativo', TJSONBool.Create(IsActive));
  Result.AddPair('inclusaoEm', DateToISO8601(CreatedAt, True));
  Result.AddPair('alteracaoEm', DateToISO8601(UpdatedAt, True));
end;

end.
