unit LabVet.Services.Exame;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.Exame;

type
  EExameValidacao = class(Exception);
  EExameNaoEncontrado = class(Exception);

  TExameService = class
  private
    procedure Validar(AValue: TExame; AIdAtual: Int64 = 0);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TExame>;
    function ObterPorId(AId: Int64): TExame;
    function Criar(AValue: TExame; AActorId: Int64): TExame;
    function Atualizar(AId: Int64; AValue: TExame; AActorId: Int64): TExame;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Models.ExameCategoria,
  LabVet.Repositories.Exame,
  LabVet.Repositories.ExameCategoria;

procedure TExameService.Validar(AValue: TExame; AIdAtual: Int64);
var
  LCategoria: TExameCategoria;
  LCategoriaRepository: TExameCategoriaRepository;
begin
  if not Assigned(AValue) then
    raise EExameValidacao.Create('Exame obrigatório.');
  if AValue.CdExame.Trim.IsEmpty or
    (Length(AValue.CdExame.Trim) > 50) then
    raise EExameValidacao.Create('Informe um código de até 50 caracteres.');
  if AValue.NmExame.Trim.IsEmpty or
    (Length(AValue.NmExame.Trim) > 200) then
    raise EExameValidacao.Create('Informe um nome de até 200 caracteres.');
  if AValue.QtTotalExames <= 0 then
    raise EExameValidacao.Create('A quantidade de exames deve ser maior que zero.');
  if AValue.VlExame.PossuiValor and (AValue.VlExame.Valor < 0) then
    raise EExameValidacao.Create('O valor do exame não pode ser negativo.');
  if AValue.IdExamePai.PossuiValor and (AValue.IdExamePai.Valor = AIdAtual) then
    raise EExameValidacao.Create('Um exame não pode ser seu próprio pai.');
  LCategoriaRepository := TExameCategoriaRepository.Create;
  try
    LCategoria := LCategoriaRepository.FindById(AValue.IdExameCategoria);
    try
      if (not Assigned(LCategoria)) or (not LCategoria.StAtivo) then
        raise EExameValidacao.Create('Categoria não encontrada ou inativa.');
    finally
      LCategoria.Free;
    end;
  finally
    LCategoriaRepository.Free;
  end;
end;

function TExameService.Listar(ApenasAtivos: Boolean): TObjectList<TExame>;
var
  LRepository: TExameRepository;
begin
  LRepository := TExameRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TExameService.ObterPorId(AId: Int64): TExame;
var
  LRepository: TExameRepository;
begin
  LRepository := TExameRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EExameNaoEncontrado.Create('Exame não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TExameService.Criar(AValue: TExame; AActorId: Int64): TExame;
var
  LExisting: TExame;
  LRepository: TExameRepository;
begin
  Validar(AValue);
  LRepository := TExameRepository.Create;
  try
    LExisting := LRepository.FindByCode(AValue.CdExame.Trim);
    try
      if Assigned(LExisting) then
        raise EExameValidacao.Create('Já existe exame com este código.');
    finally
      LExisting.Free;
    end;
    AValue.CdExame := AValue.CdExame.Trim;
    AValue.NmExame := AValue.NmExame.Trim;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TExameService.Atualizar(AId: Int64; AValue: TExame; AActorId: Int64): TExame;
var
  LRepository: TExameRepository;
begin
  Validar(AValue, AId);
  LRepository := TExameRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EExameNaoEncontrado.Create('Exame não encontrado.');
    Result.IdExameCategoria := AValue.IdExameCategoria;
    Result.CdExame := AValue.CdExame.Trim;
    Result.NmExame := AValue.NmExame.Trim;
    Result.QtTotalExames := AValue.QtTotalExames;
    Result.VlExame := AValue.VlExame;
    Result.StPrimario := AValue.StPrimario;
    Result.IdExamePai := AValue.IdExamePai;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TExameService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TExameRepository;
begin
  LRepository := TExameRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EExameNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
