unit LabVet.Controllers.Analito;

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
  LabVet.Models.Analito,
  LabVet.Services.Analito;

procedure HandleError(AException: Exception);
begin
  if (AException is EAnalitoValidacao) or
    (AException is EArgumentException) then
    raise EHorseException.New
      .Status(THTTPStatus.BadRequest)
      .Error(AException.Message);

  if AException is EAnalitoNaoEncontrado then
    raise EHorseException.New
      .Status(THTTPStatus.NotFound)
      .Error(AException.Message);

  raise EHorseException.New
    .Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

procedure List(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
var
  LAnalito: TAnalito;
  LAnalitos: TObjectList<TAnalito>;
  LResponse: TJSONArray;
  LService: TAnalitoService;
begin
  try
    LService := TAnalitoService.Create;
    try
      LAnalitos := LService.Listar;
      try
        LResponse := TJSONArray.Create;
        for LAnalito in LAnalitos do
          LResponse.AddElement(LAnalito.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LAnalitos.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Get(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
var
  LAnalito: TAnalito;
  LService: TAnalitoService;
begin
  try
    LService := TAnalitoService.Create;
    try
      LAnalito := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LAnalito.ToJSON);
      finally
        LAnalito.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Save(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc;
  AUpdate: Boolean
);
var
  LAnalito: TAnalito;
  LInput: TAnalito;
  LJSON: TJSONObject;
  LService: TAnalitoService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TAnalito.FromJSON(LJSON);
      try
        LService := TAnalitoService.Create;
        try
          if AUpdate then
          begin
            LAnalito := LService.Atualizar(
              RequestId(ARequest),
              LInput,
              CurrentUserId(ARequest)
            );
            try
              SendJSON(AResponse, LAnalito.ToJSON);
            finally
              LAnalito.Free;
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

procedure Create(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  Save(ARequest, AResponse, ANext, False);
end;

procedure Update(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  Save(ARequest, AResponse, ANext, True);
end;

procedure SetActive(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc;
  AAtivo: Boolean
);
var
  LService: TAnalitoService;
begin
  try
    LService := TAnalitoService.Create;
    try
      LService.DefinirAtivo(
        RequestId(ARequest),
        AAtivo,
        CurrentUserId(ARequest)
      );
      SendNoContent(AResponse);
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Deactivate(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  SetActive(ARequest, AResponse, ANext, False);
end;

procedure Reactivate(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  SetActive(ARequest, AResponse, ANext, True);
end;

procedure Register;
begin
  THorse.Get('/api/v1/analitos', List);
  THorse.Get('/api/v1/analitos/:id', Get);
  THorse.Post('/api/v1/analitos', Create);
  THorse.Put('/api/v1/analitos/:id', Update);
  THorse.Delete('/api/v1/analitos/:id', Deactivate);
  THorse.Post('/api/v1/analitos/:id/reativar', Reactivate);
end;

end.
