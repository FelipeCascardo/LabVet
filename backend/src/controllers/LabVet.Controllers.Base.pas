unit LabVet.Controllers.Base;

interface

uses
  System.JSON,

  Horse,
  Horse.Commons;

function RequestJSON(ARequest: THorseRequest): TJSONObject;
function RequestId(ARequest: THorseRequest): Int64;
function RequestQueryId(ARequest: THorseRequest; const AName: string): Int64;
procedure SendJSON(
  AResponse: THorseResponse;
  AJSON: TJSONValue;
  AStatus: THTTPStatus = THTTPStatus.Ok
);
procedure SendNoContent(AResponse: THorseResponse);

implementation

uses
  System.SysUtils;

function RequestJSON(ARequest: THorseRequest): TJSONObject;
var
  LValue: TJSONValue;
begin
  LValue := TJSONObject.ParseJSONValue(ARequest.Body);
  if not (LValue is TJSONObject) then
  begin
    LValue.Free;
    raise EArgumentException.Create(
      'O corpo da requisição deve ser um JSON válido.'
    );
  end;

  Result := TJSONObject(LValue);
end;

function RequestId(ARequest: THorseRequest): Int64;
begin
  if not TryStrToInt64(ARequest.Params['id'], Result) or (Result <= 0) then
    raise EArgumentException.Create('Identificador inválido.');
end;

function RequestQueryId(ARequest: THorseRequest; const AName: string): Int64;
begin
  if not TryStrToInt64(ARequest.Query[AName], Result) or (Result <= 0) then
    raise EArgumentException.Create(
      Format('Informe o parâmetro %s com um identificador válido.', [AName])
    );
end;

procedure SendJSON(
  AResponse: THorseResponse;
  AJSON: TJSONValue;
  AStatus: THTTPStatus
);
begin
  try
    AResponse
      .ContentType('application/json; charset=utf-8')
      .Status(AStatus)
      .Send(AJSON.ToJSON);
  finally
    AJSON.Free;
  end;
end;

procedure SendNoContent(AResponse: THorseResponse);
begin
  AResponse.Status(THTTPStatus.NoContent).Send('');
end;

end.
