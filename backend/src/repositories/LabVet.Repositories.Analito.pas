unit LabVet.Repositories.Analito;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.Analito,
  LabVet.Repositories.Base;

type
  TAnalitoRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TAnalito;
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TAnalito>;
    function FindById(AId: Int64): TAnalito;
    function FindByCode(const ACode: string): TAnalito;
    procedure Insert(AValue: TAnalito; AActorId: Int64);
    procedure Update(AValue: TAnalito; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TAnalitoRepository.FromQuery(AQuery: TFDQuery): TAnalito;
begin
  Result := TAnalito.Create;
  Result.IdAnalito := AQuery.FieldByName('idanalito').AsLargeInt;
  Result.CdAnalito := AQuery.FieldByName('cdanalito').AsString;
  Result.NmAnalito := AQuery.FieldByName('nmanalito').AsString;
  Result.DsTecnica := AQuery.FieldByName('dstecnica').AsString;
  Result.DsUnidadeMedida := AQuery.FieldByName('dsunidademedida').AsString;
  Result.TpValor := TTipoValorAnalito(AQuery.FieldByName('tpvalor').AsInteger);
  Result.FgPercentual := AQuery.FieldByName('fgpercentual').AsBoolean;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;
end;

function TAnalitoRepository.List(
  AOnlyActive: Boolean
): TObjectList<TAnalito>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TAnalito>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idanalito, cdanalito, nmanalito, dstecnica, dsunidademedida, ' +
      'tpvalor, fgpercentual, stativo from analitos ' +
      'where (:only_active = false or stativo = true) ' +
      'order by nmanalito';
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

function TAnalitoRepository.FindById(AId: Int64): TAnalito;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idanalito, cdanalito, nmanalito, dstecnica, dsunidademedida, ' +
      'tpvalor, fgpercentual, stativo from analitos where idanalito = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TAnalitoRepository.FindByCode(const ACode: string): TAnalito;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idanalito, cdanalito, nmanalito, dstecnica, dsunidademedida, ' +
      'tpvalor, fgpercentual, stativo from analitos ' +
      'where lower(cdanalito) = lower(:code)';
    LQuery.ParamByName('code').AsString := ACode;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TAnalitoRepository.Insert(AValue: TAnalito; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into analitos (' +
      '  cdanalito, nmanalito, dstecnica, dsunidademedida, tpvalor, fgpercentual, ' +
      '  idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      '  :code, :name, nullif(:technique, ''''), nullif(:unit, ''''), :value_type, :percentage, ' +
      '  nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idanalito, stativo';
    LQuery.ParamByName('code').AsString := AValue.CdAnalito;
    LQuery.ParamByName('name').AsString := AValue.NmAnalito;
    LQuery.ParamByName('technique').AsString := AValue.DsTecnica;
    LQuery.ParamByName('unit').AsString := AValue.DsUnidadeMedida;
    LQuery.ParamByName('value_type').AsInteger := Ord(AValue.TpValor);
    LQuery.ParamByName('percentage').AsBoolean := AValue.FgPercentual;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.Open;
    AValue.IdAnalito := LQuery.FieldByName('idanalito').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TAnalitoRepository.Update(AValue: TAnalito; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update analitos set ' +
      '  cdanalito = :code, nmanalito = :name, ' +
      '  dstecnica = nullif(:technique, ''''), ' +
      '  dsunidademedida = nullif(:unit, ''''), tpvalor = :value_type, ' +
      '  fgpercentual = :percentage, ' +
      '  idusuarioalteracao = nullif(:actor, 0) ' +
      'where idanalito = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdAnalito;
    LQuery.ParamByName('code').AsString := AValue.CdAnalito;
    LQuery.ParamByName('name').AsString := AValue.NmAnalito;
    LQuery.ParamByName('technique').AsString := AValue.DsTecnica;
    LQuery.ParamByName('unit').AsString := AValue.DsUnidadeMedida;
    LQuery.ParamByName('value_type').AsInteger := Ord(AValue.TpValor);
    LQuery.ParamByName('percentage').AsBoolean := AValue.FgPercentual;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Analito não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TAnalitoRepository.SetActive(
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
      'update analitos set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idanalito = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Analito não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
