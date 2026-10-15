unit LabVet.Controllers.ModeloExame;

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
  LabVet.Models.ModeloExame,
  LabVet.Services.ModeloExame;

procedure HandleError(AException: Exception);
begin
  if (AException is EModeloExameValidacao) or (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);
  if AException is EModeloExameNaoEncontrado then
    raise EHorseException.New.Status(THTTPStatus.NotFound).Error(AException.Message);
  raise EHorseException.New.Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

procedure List(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LModelo: TModeloExame;
  LModelos: TObjectList<TModeloExame>;
  LResponse: TJSONArray;
  LService: TModeloExameService;
begin
  try
    LService := TModeloExameService.Create;
    try
      LModelos := LService.Listar;
      try
        LResponse := TJSONArray.Create;
        for LModelo in LModelos do
          LResponse.AddElement(LModelo.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LModelos.Free;
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
  LModelo: TModeloExame;
  LService: TModeloExameService;
begin
  try
    LService := TModeloExameService.Create;
    try
      LModelo := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LModelo.ToJSON);
      finally
        LModelo.Free;
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
  LInput: TModeloExame;
  LJSON: TJSONObject;
  LModelo: TModeloExame;
  LService: TModeloExameService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TModeloExame.FromJSON(LJSON);
      try
        LService := TModeloExameService.Create;
        try
          if AUpdate then
          begin
            LModelo := LService.Atualizar(RequestId(ARequest), LInput, CurrentUserId(ARequest));
            try
              SendJSON(AResponse, LModelo.ToJSON);
            finally
              LModelo.Free;
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
  LService: TModeloExameService;
begin
  try
    LService := TModeloExameService.Create;
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
  THorse.Get('/api/v1/modelos-exames', List);
  THorse.Get('/api/v1/modelos-exames/:id', Get);
  THorse.Post('/api/v1/modelos-exames', Create);
  THorse.Put('/api/v1/modelos-exames/:id', Update);
  THorse.Delete('/api/v1/modelos-exames/:id', Deactivate);
  THorse.Post('/api/v1/modelos-exames/:id/reativar', Reactivate);
end;

end.
