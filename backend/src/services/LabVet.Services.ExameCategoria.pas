unit LabVet.Services.ExameCategoria;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.ExameCategoria;

type
  EExameCategoriaValidacao = class(Exception);
  EExameCategoriaNaoEncontrada = class(Exception);

  TExameCategoriaService = class
  private
    procedure Validar(AValue: TExameCategoria);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TExameCategoria>;
    function ObterPorId(AId: Int64): TExameCategoria;
    function Criar(AValue: TExameCategoria; AActorId: Int64): TExameCategoria;
    function Atualizar(AId: Int64; AValue: TExameCategoria; AActorId: Int64): TExameCategoria;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Repositories.ExameCategoria;

procedure TExameCategoriaService.Validar(AValue: TExameCategoria);
begin
  if not Assigned(AValue) then
    raise EExameCategoriaValidacao.Create('Categoria obrigatória.');

  if AValue.NmCategoria.Trim.IsEmpty or
    (Length(AValue.NmCategoria.Trim) > 100) then
    raise EExameCategoriaValidacao.Create('Informe uma categoria de até 100 caracteres.');
end;

function TExameCategoriaService.Listar(ApenasAtivos: Boolean): TObjectList<TExameCategoria>;
var
  LRepository: TExameCategoriaRepository;
begin
  LRepository := TExameCategoriaRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TExameCategoriaService.ObterPorId(AId: Int64): TExameCategoria;
var
  LRepository: TExameCategoriaRepository;
begin
  LRepository := TExameCategoriaRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EExameCategoriaNaoEncontrada.Create('Categoria não encontrada.');
  finally
    LRepository.Free;
  end;
end;

function TExameCategoriaService.Criar(AValue: TExameCategoria; AActorId: Int64): TExameCategoria;
var
  LExisting: TExameCategoria;
  LRepository: TExameCategoriaRepository;
begin
  Validar(AValue);
  LRepository := TExameCategoriaRepository.Create;
  try
    LExisting := LRepository.FindByName(AValue.NmCategoria.Trim);
    try
      if Assigned(LExisting) then
        raise EExameCategoriaValidacao.Create('Já existe categoria com este nome.');
    finally
      LExisting.Free;
    end;
    AValue.NmCategoria := AValue.NmCategoria.Trim;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TExameCategoriaService.Atualizar(AId: Int64; AValue: TExameCategoria; AActorId: Int64): TExameCategoria;
var
  LExisting: TExameCategoria;
  LRepository: TExameCategoriaRepository;
begin
  Validar(AValue);
  LRepository := TExameCategoriaRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EExameCategoriaNaoEncontrada.Create('Categoria não encontrada.');
    LExisting := LRepository.FindByName(AValue.NmCategoria.Trim);
    try
      if Assigned(LExisting) and (LExisting.IdExameCategoria <> AId) then
        raise EExameCategoriaValidacao.Create('Já existe categoria com este nome.');
    finally
      LExisting.Free;
    end;
    Result.NmCategoria := AValue.NmCategoria.Trim;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TExameCategoriaService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TExameCategoriaRepository;
begin
  LRepository := TExameCategoriaRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EExameCategoriaNaoEncontrada.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
