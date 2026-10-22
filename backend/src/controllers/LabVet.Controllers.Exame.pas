unit LabVet.Controllers.Exame;

interface

procedure Register;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,

  Horse,
  Horse.Commons,
  Horse.Exception,
  LabVet.Controllers.Base,
  LabVet.Middlewares.Auth,
  LabVet.Models.Exame,
  LabVet.Services.Exame;

procedure HandleError(AException: Exception);
begin
  if (AException is EExameValidacao) or (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);
  if AException is EExameNaoEncontrado then
    raise EHorseException.New.Status(THTTPStatus.NotFound).Error(AException.Message);
  raise EHorseException.New.Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

function IncluirInativos(ARequest: THorseRequest): Boolean;
var
  LValor: string;
begin
  LValor := ARequest.Query['incluirInativos'];
  Result := SameText(LValor, 'true') or (LValor = '1');
end;

procedure List(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LExame: TExame;
  LExames: TObjectList<TExame>;
  LResponse: TJSONArray;
  LService: TExameService;
begin
  try
    LService := TExameService.Create;
    try
      LExames := LService.Listar(not IncluirInativos(ARequest));
      try
        LResponse := TJSONArray.Create;
        for LExame in LExames do
          LResponse.AddElement(LExame.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LExames.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Get(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LExame: TExame;
  LService: TExameService;
begin
  try
    LService := TExameService.Create;
    try
      LExame := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LExame.ToJSON);
      finally
        LExame.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Save(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc; AUpdate: Boolean);
var
  LExame: TExame;
  LInput: TExame;
  LJSON: TJSONObject;
  LService: TExameService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TExame.FromJSON(LJSON);
      try
        LService := TExameService.Create;
        try
          if AUpdate then
          begin
            LExame := LService.Atualizar(RequestId(ARequest), LInput, CurrentUserId(ARequest));
            try
              SendJSON(AResponse, LExame.ToJSON);
            finally
              LExame.Free;
            end;
          end
          else
          begin
            LService.Criar(LInput, CurrentUserId(ARequest));
            SendJSON(AResponse, LInput.ToJSON, THTTPStatus.Created);
          end;
        finally
          LService.Free;
        end;
      finally
        LInput.Free;
      end;
    finally
      LJSON.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Create(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
begin
  Save(ARequest, AResponse, ANext, False);
end;

procedure Update(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
begin
  Save(ARequest, AResponse, ANext, True);
end;

procedure SetActive(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc; AAtivo: Boolean);
var
  LService: TExameService;
begin
  try
    LService := TExameService.Create;
    try
      LService.DefinirAtivo(RequestId(ARequest), AAtivo, CurrentUserId(ARequest));
      SendNoContent(AResponse);
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Deactivate(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
begin
  SetActive(ARequest, AResponse, ANext, False);
end;

procedure Reactivate(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
begin
  SetActive(ARequest, AResponse, ANext, True);
end;

procedure Register;
begin
  THorse.Get('/api/v1/exames', List);
  THorse.Get('/api/v1/exames/:id', Get);
  THorse.Post('/api/v1/exames', Create);
  THorse.Put('/api/v1/exames/:id', Update);
  THorse.Delete('/api/v1/exames/:id', Deactivate);
  THorse.Post('/api/v1/exames/:id/reativar', Reactivate);
end;

end.
