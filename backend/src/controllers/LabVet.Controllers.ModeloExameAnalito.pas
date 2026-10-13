unit LabVet.Controllers.ModeloExameAnalito;

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
  LabVet.Models.ModeloExameAnalito,
  LabVet.Services.ModeloExameAnalito;

procedure HandleError(AException: Exception);
begin
  if (AException is EModeloExameAnalitoValidacao) or
    (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);

  if AException is EModeloExameAnalitoNaoEncontrado then
    raise EHorseException.New.Status(THTTPStatus.NotFound).Error(AException.Message);

  raise EHorseException.New.Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

procedure List(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LItem: TModeloExameAnalito;
  LItens: TObjectList<TModeloExameAnalito>;
  LResponse: TJSONArray;
  LService: TModeloExameAnalitoService;
begin
  try
    LService := TModeloExameAnalitoService.Create;
    try
      LItens := LService.ListarPorModelo(RequestQueryId(ARequest, 'idModeloExame'));
      try
        LResponse := TJSONArray.Create;
        for LItem in LItens do
          LResponse.AddElement(LItem.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LItens.Free;
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
  LItem: TModeloExameAnalito;
  LService: TModeloExameAnalitoService;
begin
  try
    LService := TModeloExameAnalitoService.Create;
    try
      LItem := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LItem.ToJSON);
      finally
        LItem.Free;
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
  LInput: TModeloExameAnalito;
  LItem: TModeloExameAnalito;
  LJSON: TJSONObject;
  LService: TModeloExameAnalitoService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TModeloExameAnalito.FromJSON(LJSON);
      try
        LService := TModeloExameAnalitoService.Create;
        try
          if AUpdate then
          begin
            LItem := LService.Atualizar(RequestId(ARequest), LInput, CurrentUserId(ARequest));
            try
              SendJSON(AResponse, LItem.ToJSON);
            finally
              LItem.Free;
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
  LService: TModeloExameAnalitoService;
begin
  try
    LService := TModeloExameAnalitoService.Create;
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
  THorse.Get('/api/v1/modelos-exames-analitos', List);
  THorse.Get('/api/v1/modelos-exames-analitos/:id', Get);
  THorse.Post('/api/v1/modelos-exames-analitos', Create);
  THorse.Put('/api/v1/modelos-exames-analitos/:id', Update);
  THorse.Delete('/api/v1/modelos-exames-analitos/:id', Deactivate);
  THorse.Post('/api/v1/modelos-exames-analitos/:id/reativar', Reactivate);
end;

end.
