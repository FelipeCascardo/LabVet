unit LabVet.Controllers.ExameAnalito;

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
  LabVet.Models.ExameAnalito,
  LabVet.Services.ExameAnalito;

procedure HandleError(AException: Exception);
begin
  if (AException is EExameAnalitoValidacao) or (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);
  if AException is EExameAnalitoNaoEncontrado then
    raise EHorseException.New.Status(THTTPStatus.NotFound).Error(AException.Message);
  raise EHorseException.New.Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

procedure List(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LExameAnalito: TExameAnalito;
  LExameAnalitos: TObjectList<TExameAnalito>;
  LResponse: TJSONArray;
  LService: TExameAnalitoService;
begin
  try
    LService := TExameAnalitoService.Create;
    try
      LExameAnalitos := LService.Listar;
      try
        LResponse := TJSONArray.Create;
        for LExameAnalito in LExameAnalitos do
          LResponse.AddElement(LExameAnalito.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LExameAnalitos.Free;
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
  LExameAnalito: TExameAnalito;
  LService: TExameAnalitoService;
begin
  try
    LService := TExameAnalitoService.Create;
    try
      LExameAnalito := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LExameAnalito.ToJSON);
      finally
        LExameAnalito.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Create(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LInput: TExameAnalito;
  LJSON: TJSONObject;
  LService: TExameAnalitoService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TExameAnalito.FromJSON(LJSON);
      try
        LService := TExameAnalitoService.Create;
        try
          LService.Criar(LInput, CurrentUserId(ARequest));
          SendJSON(AResponse, LInput.ToJSON, THTTPStatus.Created);
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

procedure Update(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
var
  LInput: TExameAnalito;
  LItem: TExameAnalito;
  LJSON: TJSONObject;
  LService: TExameAnalitoService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TExameAnalito.FromJSON(LJSON);
      try
        LService := TExameAnalitoService.Create;
        try
          LItem := LService.Atualizar(
            RequestId(ARequest),
            LInput,
            CurrentUserId(ARequest)
          );
          try
            SendJSON(AResponse, LItem.ToJSON);
          finally
            LItem.Free;
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

procedure SetActive(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc; AAtivo: Boolean);
var
  LService: TExameAnalitoService;
begin
  try
    LService := TExameAnalitoService.Create;
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
  THorse.Get('/api/v1/exame-analitos', List);
  THorse.Get('/api/v1/exame-analitos/:id', Get);
  THorse.Post('/api/v1/exame-analitos', Create);
  THorse.Put('/api/v1/exame-analitos/:id', Update);
  THorse.Delete('/api/v1/exame-analitos/:id', Deactivate);
  THorse.Post('/api/v1/exame-analitos/:id/reativar', Reactivate);
end;

end.
