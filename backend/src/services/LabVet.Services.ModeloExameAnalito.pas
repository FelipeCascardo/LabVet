unit LabVet.Services.ModeloExameAnalito;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.ModeloExameAnalito;

type
  EModeloExameAnalitoValidacao = class(Exception);
  EModeloExameAnalitoNaoEncontrado = class(Exception);

  TModeloExameAnalitoService = class
  private
    procedure Validar(AValue: TModeloExameAnalito);
  public
    function ListarPorModelo(AIdModeloExame: Int64): TObjectList<TModeloExameAnalito>;
    function ObterPorId(AId: Int64): TModeloExameAnalito;
    function Criar(AValue: TModeloExameAnalito; AActorId: Int64): TModeloExameAnalito;
    function Atualizar(AId: Int64; AValue: TModeloExameAnalito; AActorId: Int64): TModeloExameAnalito;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Repositories.ModeloExameAnalito;

procedure TModeloExameAnalitoService.Validar(AValue: TModeloExameAnalito);
begin
  if not Assigned(AValue) then
    raise EModeloExameAnalitoValidacao.Create('Item do modelo obrigatório.');
  if AValue.NrExibicao <= 0 then
    raise EModeloExameAnalitoValidacao.Create('A ordem de exibição deve ser maior que zero.');
  if AValue.VrRefMinimo.PossuiValor and AValue.VrRefMaximo.PossuiValor and
    (AValue.VrRefMinimo.Valor > AValue.VrRefMaximo.Valor) then
    raise EModeloExameAnalitoValidacao.Create(
      'A referência mínima não pode ser maior que a máxima.'
    );
end;

function TModeloExameAnalitoService.ListarPorModelo(AIdModeloExame: Int64): TObjectList<TModeloExameAnalito>;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.ListByModelo(AIdModeloExame);
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.ObterPorId(AId: Int64): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EModeloExameAnalitoNaoEncontrado.Create('Item do modelo não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.Criar(AValue: TModeloExameAnalito; AActorId: Int64): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  Validar(AValue);
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.Atualizar(AId: Int64; AValue: TModeloExameAnalito; AActorId: Int64): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  Validar(AValue);
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EModeloExameAnalitoNaoEncontrado.Create('Item do modelo não encontrado.');
    Result.IdExameAnalito := AValue.IdExameAnalito;
    Result.DsSecao := AValue.DsSecao.Trim;
    Result.NrExibicao := AValue.NrExibicao;
    Result.DsRotulo := AValue.DsRotulo.Trim;
    Result.DsTecnica := AValue.DsTecnica.Trim;
    Result.DsUnidadeMedida := AValue.DsUnidadeMedida.Trim;
    Result.DsReferencia := AValue.DsReferencia.Trim;
    Result.VrRefMinimo := AValue.VrRefMinimo;
    Result.VrRefMaximo := AValue.VrRefMaximo;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TModeloExameAnalitoService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EModeloExameAnalitoNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
