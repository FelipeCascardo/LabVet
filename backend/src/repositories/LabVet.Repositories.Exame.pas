unit LabVet.Repositories.Exame;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.Exame,
  LabVet.Repositories.Base;

type
  TExameRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TExame;
    procedure SetOptionalFields(AQuery: TFDQuery; AValue: TExame);
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TExame>;
    function FindById(AId: Int64): TExame;
    function FindByCode(const ACode: string): TExame;
    procedure Insert(AValue: TExame; AActorId: Int64);
    procedure Update(AValue: TExame; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TExameRepository.FromQuery(AQuery: TFDQuery): TExame;
begin
  Result := TExame.Create;
  Result.IdExame := AQuery.FieldByName('idexame').AsLargeInt;
  Result.IdExameCategoria := AQuery.FieldByName('idexamecategoria').AsLargeInt;
  Result.CdExame := AQuery.FieldByName('cdexame').AsString;
  Result.NmExame := AQuery.FieldByName('nmexame').AsString;
  Result.QtTotalExames := AQuery.FieldByName('qttotalexames').AsInteger;
  Result.StPrimario := AQuery.FieldByName('stprimario').AsBoolean;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;

  Result.VlExame.PossuiValor := not AQuery.FieldByName('vlexame').IsNull;
  if Result.VlExame.PossuiValor then
    Result.VlExame.Valor := AQuery.FieldByName('vlexame').AsCurrency;

  Result.IdExamePai.PossuiValor := not AQuery.FieldByName('idexamepai').IsNull;
  if Result.IdExamePai.PossuiValor then
    Result.IdExamePai.Valor := AQuery.FieldByName('idexamepai').AsLargeInt;
end;

procedure TExameRepository.SetOptionalFields(
  AQuery: TFDQuery;
  AValue: TExame
);
begin
  if AValue.VlExame.PossuiValor then
    AQuery.ParamByName('price').AsCurrency := AValue.VlExame.Valor
  else
    AQuery.ParamByName('price').Clear;

  if AValue.IdExamePai.PossuiValor then
    AQuery.ParamByName('parent_id').AsLargeInt := AValue.IdExamePai.Valor
  else
    AQuery.ParamByName('parent_id').Clear;
end;

function TExameRepository.List(
  AOnlyActive: Boolean
): TObjectList<TExame>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TExame>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexame, idexamecategoria, cdexame, nmexame, qttotalexames, ' +
      'vlexame, stprimario, idexamepai, stativo ' +
      'from exames ' +
      'where (:only_active = false or stativo = true) ' +
      'order by nmexame';
    LQuery.ParamByName('only_active').AsBoolean := AOnlyActive;
    LQuery.Open;
    while not LQuery.Eof do
    begin
      Result.Add(FromQuery(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TExameRepository.FindById(AId: Int64): TExame;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexame, idexamecategoria, cdexame, nmexame, qttotalexames, ' +
      'vlexame, stprimario, idexamepai, stativo ' +
      'from exames where idexame = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TExameRepository.FindByCode(const ACode: string): TExame;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexame, idexamecategoria, cdexame, nmexame, qttotalexames, ' +
      'vlexame, stprimario, idexamepai, stativo ' +
      'from exames where lower(cdexame) = lower(:code)';
    LQuery.ParamByName('code').AsString := ACode;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TExameRepository.Insert(AValue: TExame; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into exames (' +
      '  idexamecategoria, cdexame, nmexame, qttotalexames, vlexame, ' +
      '  stprimario, idexamepai, idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      '  :category_id, :code, :name, :quantity, :price, :primary, :parent_id, ' +
      '  nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idexame, stativo';
    LQuery.ParamByName('category_id').AsLargeInt := AValue.IdExameCategoria;
    LQuery.ParamByName('code').AsString := AValue.CdExame;
    LQuery.ParamByName('name').AsString := AValue.NmExame;
    LQuery.ParamByName('quantity').AsInteger := AValue.QtTotalExames;
    LQuery.ParamByName('primary').AsBoolean := AValue.StPrimario;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetOptionalFields(LQuery, AValue);
    LQuery.Open;
    AValue.IdExame := LQuery.FieldByName('idexame').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TExameRepository.Update(AValue: TExame; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update exames set ' +
      '  idexamecategoria = :category_id, cdexame = :code, nmexame = :name, ' +
      '  qttotalexames = :quantity, vlexame = :price, stprimario = :primary, ' +
      '  idexamepai = :parent_id, idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexame = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdExame;
    LQuery.ParamByName('category_id').AsLargeInt := AValue.IdExameCategoria;
    LQuery.ParamByName('code').AsString := AValue.CdExame;
    LQuery.ParamByName('name').AsString := AValue.NmExame;
    LQuery.ParamByName('quantity').AsInteger := AValue.QtTotalExames;
    LQuery.ParamByName('primary').AsBoolean := AValue.StPrimario;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetOptionalFields(LQuery, AValue);
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Exame não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TExameRepository.SetActive(
  AId: Int64;
  AActive: Boolean;
  AActorId: Int64
);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update exames set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexame = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Exame não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
