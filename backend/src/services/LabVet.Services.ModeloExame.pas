unit LabVet.Services.ModeloExame;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.ModeloExame;

type
  EModeloExameValidacao = class(Exception);
  EModeloExameNaoEncontrado = class(Exception);

  TModeloExameService = class
  private
    procedure Validar(AValue: TModeloExame);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TModeloExame>;
    function ObterPorId(AId: Int64): TModeloExame;
    function Criar(AValue: TModeloExame; AActorId: Int64): TModeloExame;
    function Atualizar(
      AId: Int64;
      AValue: TModeloExame;
      AActorId: Int64
    ): TModeloExame;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Repositories.ModeloExame;

procedure TModeloExameService.Validar(AValue: TModeloExame);
begin
  if not Assigned(AValue) then
    raise EModeloExameValidacao.Create('Modelo de exame obrigatório.');
  if AValue.CdModeloLaudo.Trim.IsEmpty or
    (Length(AValue.CdModeloLaudo.Trim) > 100) then
    raise EModeloExameValidacao.Create('Informe um código de até 100 caracteres.');
  if AValue.NmModeloLaudo.Trim.IsEmpty or
    (Length(AValue.NmModeloLaudo.Trim) > 250) then
    raise EModeloExameValidacao.Create('Informe um nome de até 250 caracteres.');
end;

function TModeloExameService.Listar(
  ApenasAtivos: Boolean
): TObjectList<TModeloExame>;
var
  LRepository: TModeloExameRepository;
begin
  LRepository := TModeloExameRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TModeloExameService.ObterPorId(AId: Int64): TModeloExame;
var
  LRepository: TModeloExameRepository;
begin
  LRepository := TModeloExameRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EModeloExameNaoEncontrado.Create('Modelo de exame não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TModeloExameService.Criar(
  AValue: TModeloExame;
  AActorId: Int64
): TModeloExame;
var
  LExisting: TModeloExame;
  LRepository: TModeloExameRepository;
begin
  Validar(AValue);

  LRepository := TModeloExameRepository.Create;
  try
    LExisting := LRepository.FindByCode(AValue.CdModeloLaudo.Trim);
    try
      if Assigned(LExisting) then
        raise EModeloExameValidacao.Create('Já existe modelo de exame com este código.');
    finally
      LExisting.Free;
    end;

    AValue.CdModeloLaudo := AValue.CdModeloLaudo.Trim;
    AValue.NmModeloLaudo := AValue.NmModeloLaudo.Trim;
    AValue.DsFaixaIdade := AValue.DsFaixaIdade.Trim;
    AValue.NmArquivoOrigem := AValue.NmArquivoOrigem.Trim;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TModeloExameService.Atualizar(
  AId: Int64;
  AValue: TModeloExame;
  AActorId: Int64
): TModeloExame;
var
  LExisting: TModeloExame;
  LRepository: TModeloExameRepository;
begin
  Validar(AValue);

  LRepository := TModeloExameRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EModeloExameNaoEncontrado.Create('Modelo de exame não encontrado.');

    LExisting := LRepository.FindByCode(AValue.CdModeloLaudo.Trim);
    try
      if Assigned(LExisting) and (LExisting.IdModeloExame <> AId) then
        raise EModeloExameValidacao.Create('Já existe modelo de exame com este código.');
    finally
      LExisting.Free;
    end;

    Result.IdExame := AValue.IdExame;
    Result.IdAnimalGrupo := AValue.IdAnimalGrupo;
    Result.CdModeloLaudo := AValue.CdModeloLaudo.Trim;
    Result.NmModeloLaudo := AValue.NmModeloLaudo.Trim;
    Result.DsFaixaIdade := AValue.DsFaixaIdade.Trim;
    Result.NmArquivoOrigem := AValue.NmArquivoOrigem.Trim;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TModeloExameService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TModeloExameRepository;
begin
  LRepository := TModeloExameRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EModeloExameNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
