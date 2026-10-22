unit LabVet.Controllers.AnimalGrupo;

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
  LabVet.Models.AnimalGrupo,
  LabVet.Services.AnimalGrupo;

procedure HandleError(AException: Exception);
begin
  if (AException is EAnimalGrupoValidacao) or (AException is EArgumentException) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(AException.Message);
  if AException is EAnimalGrupoNaoEncontrado then
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
  LGrupo: TAnimalGrupo;
  LGrupos: TObjectList<TAnimalGrupo>;
  LResponse: TJSONArray;
  LService: TAnimalGrupoService;
begin
  try
    LService := TAnimalGrupoService.Create;
    try
      LGrupos := LService.Listar(not IncluirInativos(ARequest));
      try
        LResponse := TJSONArray.Create;
        for LGrupo in LGrupos do
          LResponse.AddElement(LGrupo.ToJSON);
        SendJSON(AResponse, LResponse);
      finally
        LGrupos.Free;
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
  LGrupo: TAnimalGrupo;
  LService: TAnimalGrupoService;
begin
  try
    LService := TAnimalGrupoService.Create;
    try
      LGrupo := LService.ObterPorId(RequestId(ARequest));
      try
        SendJSON(AResponse, LGrupo.ToJSON);
      finally
        LGrupo.Free;
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
  LGrupo: TAnimalGrupo;
  LInput: TAnimalGrupo;
  LJSON: TJSONObject;
  LService: TAnimalGrupoService;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TAnimalGrupo.FromJSON(LJSON);
      try
        LService := TAnimalGrupoService.Create;
        try
          if AUpdate then
          begin
            LGrupo := LService.Atualizar(RequestId(ARequest), LInput, CurrentUserId(ARequest));
            try
              SendJSON(AResponse, LGrupo.ToJSON);
            finally
              LGrupo.Free;
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
  LService: TAnimalGrupoService;
begin
  try
    LService := TAnimalGrupoService.Create;
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
  THorse.Get('/api/v1/animal-grupos', List);
  THorse.Get('/api/v1/animal-grupos/:id', Get);
  THorse.Post('/api/v1/animal-grupos', Create);
  THorse.Put('/api/v1/animal-grupos/:id', Update);
  THorse.Delete('/api/v1/animal-grupos/:id', Deactivate);
  THorse.Post('/api/v1/animal-grupos/:id/reativar', Reactivate);
end;

end.
