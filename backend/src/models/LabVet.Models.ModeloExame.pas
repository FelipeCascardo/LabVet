unit LabVet.Models.ModeloExame;

interface

uses
  System.Generics.Collections,
  LabVet.Models.Analito,
  LabVet.Models.Exame,
  LabVet.Models.ExameAnalito,
  LabVet.Models.ModeloExameAnalito,
  LabVet.Models.ModeloLaudo,
  LabVet.Models.TipoAnimal;

type
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
    FModeloLaudo: TModeloLaudo;
    FTipoAnimal: TTipoAnimal;
    procedure SetExame(AValue: TExame);
    procedure SetModeloLaudo(AValue: TModeloLaudo);
    procedure SetTipoAnimal(AValue: TTipoAnimal);
  public
    constructor Create;
    destructor Destroy; override;
    property Analitos: TObjectList<TModeloExameAnalitoDetalhe> read FAnalitos;
    property Exame: TExame read FExame write SetExame;
    property ModeloLaudo: TModeloLaudo read FModeloLaudo write SetModeloLaudo;
    property TipoAnimal: TTipoAnimal read FTipoAnimal write SetTipoAnimal;
  end;

implementation

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
  FModeloLaudo := TModeloLaudo.Create;
end;

destructor TModeloExameDetalhe.Destroy;
begin
  FAnalitos.Free;
  FExame.Free;
  FModeloLaudo.Free;
  FTipoAnimal.Free;
  inherited Destroy;
end;

procedure TModeloExameDetalhe.SetExame(AValue: TExame);
begin
  if FExame = AValue then
    Exit;

  FExame.Free;
  FExame := AValue;
end;

procedure TModeloExameDetalhe.SetModeloLaudo(AValue: TModeloLaudo);
begin
  if FModeloLaudo = AValue then
    Exit;

  FModeloLaudo.Free;
  FModeloLaudo := AValue;
end;

procedure TModeloExameDetalhe.SetTipoAnimal(AValue: TTipoAnimal);
begin
  if FTipoAnimal = AValue then
    Exit;

  FTipoAnimal.Free;
  FTipoAnimal := AValue;
end;

end.
