unit LabVet.Services.ExameAnalito;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.ExameAnalito;

type
  EExameAnalitoValidacao = class(Exception);
  EExameAnalitoNaoEncontrado = class(Exception);

  TExameAnalitoService = class
  private
    procedure Validar(AValue: TExameAnalito);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TExameAnalito>;
    function ObterPorId(AId: Int64): TExameAnalito;
    function Criar(AValue: TExameAnalito; AActorId: Int64): TExameAnalito;
    function Atualizar(
      AId: Int64;
      AValue: TExameAnalito;
      AActorId: Int64
    ): TExameAnalito;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Models.Analito,
  LabVet.Models.Exame,
  LabVet.Repositories.Analito,
  LabVet.Repositories.Exame,
  LabVet.Repositories.ExameAnalito;

procedure TExameAnalitoService.Validar(AValue: TExameAnalito);
var
  LAnalito: TAnalito;
  LAnalitoRepository: TAnalitoRepository;
  LExame: TExame;
  LExameRepository: TExameRepository;
begin
  if not Assigned(AValue) then
    raise EExameAnalitoValidacao.Create('Vínculo obrigatório.');

  LExameRepository := TExameRepository.Create;
  LAnalitoRepository := TAnalitoRepository.Create;
  try
    LExame := LExameRepository.FindById(AValue.IdExame);
    LAnalito := LAnalitoRepository.FindById(AValue.IdAnalito);
    try
      if (not Assigned(LExame)) or (not LExame.StAtivo) then
        raise EExameAnalitoValidacao.Create('Exame não encontrado ou inativo.');
      if (not Assigned(LAnalito)) or (not LAnalito.StAtivo) then
        raise EExameAnalitoValidacao.Create('Analito não encontrado ou inativo.');
    finally
      LAnalito.Free;
      LExame.Free;
    end;
  finally
    LAnalitoRepository.Free;
    LExameRepository.Free;
  end;
end;

function TExameAnalitoService.Listar(ApenasAtivos: Boolean): TObjectList<TExameAnalito>;
var
  LRepository: TExameAnalitoRepository;
begin
  LRepository := TExameAnalitoRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TExameAnalitoService.ObterPorId(AId: Int64): TExameAnalito;
var
  LRepository: TExameAnalitoRepository;
begin
  LRepository := TExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EExameAnalitoNaoEncontrado.Create('Vínculo não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TExameAnalitoService.Criar(AValue: TExameAnalito; AActorId: Int64): TExameAnalito;
var
  LExisting: TExameAnalito;
  LRepository: TExameAnalitoRepository;
begin
  Validar(AValue);
  LRepository := TExameAnalitoRepository.Create;
  try
    LExisting := LRepository.FindByExameAnalito(AValue.IdExame, AValue.IdAnalito);
    try
      if Assigned(LExisting) then
        raise EExameAnalitoValidacao.Create('O analito já está vinculado ao exame.');
    finally
      LExisting.Free;
    end;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TExameAnalitoService.Atualizar(
  AId: Int64;
  AValue: TExameAnalito;
  AActorId: Int64
): TExameAnalito;
var
  LRepository: TExameAnalitoRepository;
  LSameLink: TExameAnalito;
begin
  Validar(AValue);

  LRepository := TExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EExameAnalitoNaoEncontrado.Create('Vínculo não encontrado.');

    LSameLink := LRepository.FindByExameAnalito(
      AValue.IdExame,
      AValue.IdAnalito
    );
    try
      if Assigned(LSameLink) and (LSameLink.IdExameAnalito <> AId) then
        raise EExameAnalitoValidacao.Create(
          'O analito já está vinculado ao exame.'
        );
    finally
      LSameLink.Free;
    end;

    Result.IdExame := AValue.IdExame;
    Result.IdAnalito := AValue.IdAnalito;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TExameAnalitoService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TExameAnalitoRepository;
begin
  LRepository := TExameAnalitoRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EExameAnalitoNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
