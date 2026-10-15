unit LabVet.Models.Exame;

interface

uses
  System.JSON,
  System.SysUtils,
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
    class function FromJSON(AJSON: TJSONObject): TExame; static;
    function ToJSON: TJSONObject;
    property Categoria: TExameCategoria read FCategoria write SetCategoria;
  end;

implementation

class function TExame.FromJSON(AJSON: TJSONObject): TExame;
var
  LValue: TJSONValue;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  Result := TExame.Create;
  Result.IdExameCategoria := AJSON.GetValue<Int64>('idCategoria');
  Result.CdExame := AJSON.GetValue<string>('codigo');
  Result.NmExame := AJSON.GetValue<string>('nome');
  Result.QtTotalExames := AJSON.GetValue<Integer>('quantidade');
  Result.StPrimario := AJSON.GetValue<Boolean>('primario');
  LValue := AJSON.GetValue('valor');
  if Assigned(LValue) and not (LValue is TJSONNull) then
  begin
    Result.VlExame.PossuiValor := True;
    Result.VlExame.Valor := LValue.GetValue<Currency>;
  end;
  LValue := AJSON.GetValue('idExamePai');
  if Assigned(LValue) and not (LValue is TJSONNull) then
  begin
    Result.IdExamePai.PossuiValor := True;
    Result.IdExamePai.Valor := LValue.GetValue<Int64>;
  end;
end;

function TExame.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdExame));
  Result.AddPair('idCategoria', TJSONNumber.Create(IdExameCategoria));
  Result.AddPair('codigo', CdExame);
  Result.AddPair('nome', NmExame);
  Result.AddPair('quantidade', TJSONNumber.Create(QtTotalExames));
  Result.AddPair('primario', TJSONBool.Create(StPrimario));
  if VlExame.PossuiValor then Result.AddPair('valor', TJSONNumber.Create(VlExame.Valor)) else Result.AddPair('valor', TJSONNull.Create);
  if IdExamePai.PossuiValor then Result.AddPair('idExamePai', TJSONNumber.Create(IdExamePai.Valor)) else Result.AddPair('idExamePai', TJSONNull.Create);
  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

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
