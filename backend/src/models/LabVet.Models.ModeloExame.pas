unit LabVet.Models.ModeloExame;

interface

uses
  System.Generics.Collections,
  LabVet.Models.Base,
  LabVet.Models.Analito,
  LabVet.Models.Exame,
  LabVet.Models.ExameAnalito,
  LabVet.Models.ModeloExameAnalito,
  LabVet.Models.AnimalGrupo;

type
  TModeloExame = class(TEntidadeAuditavel)
  public
    IdModeloExame: Int64;
    IdExame: TInteiro64Opcional;
    IdAnimalGrupo: TInteiro64Opcional;
    CdModeloLaudo: string;
    NmModeloLaudo: string;
    DsFaixaIdade: string;
    NmArquivoOrigem: string;
    constructor Create;
  end;

  TModeloExameAnalitoDetalhe = class
  private
    FAnalito: TAnalito;
    FConfiguracao: TModeloExameAnalito;
    FVinculoExame: TExameAnalito;
    procedure SetAnalito(AValue: TAnalito);
    procedure SetConfiguracao(AValue: TModeloExameAnalito);
    procedure SetVinculoExame(AValue: TExameAnalito);
  public
    constructor Create;
    destructor Destroy; override;
    property Analito: TAnalito read FAnalito write SetAnalito;
    property Configuracao: TModeloExameAnalito read FConfiguracao write SetConfiguracao;
    property VinculoExame: TExameAnalito read FVinculoExame write SetVinculoExame;
  end;

  TModeloExameDetalhe = class
  private
    FAnalitos: TObjectList<TModeloExameAnalitoDetalhe>;
    FExame: TExame;
    FModeloExame: TModeloExame;
    FAnimalGrupo: TAnimalGrupo;
    procedure SetExame(AValue: TExame);
    procedure SetModeloExame(AValue: TModeloExame);
    procedure SetAnimalGrupo(AValue: TAnimalGrupo);
  public
    constructor Create;
    destructor Destroy; override;
    property Analitos: TObjectList<TModeloExameAnalitoDetalhe> read FAnalitos;
    property Exame: TExame read FExame write SetExame;
    property ModeloExame: TModeloExame read FModeloExame write SetModeloExame;
    property AnimalGrupo: TAnimalGrupo read FAnimalGrupo write SetAnimalGrupo;
  end;

implementation

constructor TModeloExame.Create;
begin
  inherited Create;
  StAtivo := True;
end;

constructor TModeloExameAnalitoDetalhe.Create;
begin
  inherited Create;
  FAnalito := TAnalito.Create;
  FConfiguracao := TModeloExameAnalito.Create;
  FVinculoExame := TExameAnalito.Create;
end;

destructor TModeloExameAnalitoDetalhe.Destroy;
begin
  FAnalito.Free;
  FConfiguracao.Free;
  FVinculoExame.Free;
  inherited Destroy;
end;

procedure TModeloExameAnalitoDetalhe.SetAnalito(AValue: TAnalito);
begin
  if FAnalito = AValue then
    Exit;

  FAnalito.Free;
  FAnalito := AValue;
end;

procedure TModeloExameAnalitoDetalhe.SetConfiguracao(AValue: TModeloExameAnalito);
begin
  if FConfiguracao = AValue then
    Exit;

  FConfiguracao.Free;
  FConfiguracao := AValue;
end;

procedure TModeloExameAnalitoDetalhe.SetVinculoExame(AValue: TExameAnalito);
begin
  if FVinculoExame = AValue then
    Exit;

  FVinculoExame.Free;
  FVinculoExame := AValue;
end;

constructor TModeloExameDetalhe.Create;
begin
  inherited Create;
  FAnalitos := TObjectList<TModeloExameAnalitoDetalhe>.Create(True);
  FExame := TExame.Create;
  FModeloExame := TModeloExame.Create;
end;

destructor TModeloExameDetalhe.Destroy;
begin
  FAnalitos.Free;
  FExame.Free;
  FModeloExame.Free;
  FAnimalGrupo.Free;
  inherited Destroy;
end;

procedure TModeloExameDetalhe.SetExame(AValue: TExame);
begin
  if FExame = AValue then
    Exit;

  FExame.Free;
  FExame := AValue;
end;

procedure TModeloExameDetalhe.SetModeloExame(AValue: TModeloExame);
begin
  if FModeloExame = AValue then
    Exit;

  FModeloExame.Free;
  FModeloExame := AValue;
end;

procedure TModeloExameDetalhe.SetAnimalGrupo(AValue: TAnimalGrupo);
begin
  if FAnimalGrupo = AValue then
    Exit;

  FAnimalGrupo.Free;
  FAnimalGrupo := AValue;
end;

end.
