unit LabVet.Models.Exame;

interface

uses
  LabVet.Models.Base,
  LabVet.Models.ExameCategoria;

type
  TExame = class(TEntidadeAuditavel)
  private
    FCategoria: TExameCategoria;
    procedure SetCategoria(AValue: TExameCategoria);
  public
    IdExame: Int64;
    IdExameCategoria: Int64;
    CdExame: string;
    NmExame: string;
    QtTotalExames: Integer;
    VlExame: TMoedaOpcional;
    StPrimario: Boolean;
    IdExamePai: TInteiro64Opcional;
    constructor Create;
    destructor Destroy; override;
    property Categoria: TExameCategoria read FCategoria write SetCategoria;
  end;

implementation

constructor TExame.Create;
begin
  inherited Create;
  StAtivo := True;
  StPrimario := True;
  QtTotalExames := 1;
end;

destructor TExame.Destroy;
begin
  FCategoria.Free;
  inherited Destroy;
end;

procedure TExame.SetCategoria(AValue: TExameCategoria);
begin
  if FCategoria = AValue then
    Exit;

  FCategoria.Free;
  FCategoria := AValue;
end;

end.
