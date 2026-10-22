unit LabVet.Controllers.ExameCategoria;

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
  LabVet.Models.ExameCategoria,
  LabVet.Services.ExameCategoria;

procedure HandleError(AException: Exception);
begin
  if (AException is EExameCategoriaValidacao) or
    (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);

  if AException is EExameCategoriaNaoEncontrada then
    raise EHorseException.New.Status(THTTPStatus.NotFound).Error(AException.Message);

  raise EHorseException.New
    .Status(THTTPStatus.InternalServerError)
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
  LCategorias: TObjectList<TExameCategoria>;
  LCategoria: TExameCategoria;
  LResponse: TJSONArray;
  LService: TExameCategoriaService;
begin
  try
    LService := TExameCategoriaService.Create;
    try
      LCategorias := LService.Listar(not IncluirInativos(ARequest));
      try
        LResponse := TJSONArray.Create;
        for LCategoria in LCategorias do
          LResponse.AddElement(LCategoria.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LCategorias.Free;
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
  LCategoria: TExameCategoria;
  LService: TExameCategoriaService;
begin
  try
    LService := TExameCategoriaService.Create;
    try
      LCategoria := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LCategoria.ToJSON);
      finally
        LCategoria.Free;
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
  LCategoria: TExameCategoria;
  LInput: TExameCategoria;
  LJSON: TJSONObject;
  LService: TExameCategoriaService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TExameCategoria.FromJSON(LJSON);
      try
        LService := TExameCategoriaService.Create;
        try
          if AUpdate then
          begin
            LCategoria := LService.Atualizar(RequestId(ARequest), LInput, CurrentUserId(ARequest));
            try
              SendJSON(AResponse, LCategoria.ToJSON);
            finally
              LCategoria.Free;
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
  LService: TExameCategoriaService;
begin
  try
    LService := TExameCategoriaService.Create;
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
  THorse.Get('/api/v1/exame-categorias', List);
  THorse.Get('/api/v1/exame-categorias/:id', Get);
  THorse.Post('/api/v1/exame-categorias', Create);
  THorse.Put('/api/v1/exame-categorias/:id', Update);
  THorse.Delete('/api/v1/exame-categorias/:id', Deactivate);
  THorse.Post('/api/v1/exame-categorias/:id/reativar', Reactivate);
end;

end.
