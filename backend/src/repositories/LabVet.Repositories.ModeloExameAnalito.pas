unit LabVet.Repositories.ModeloExameAnalito;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.ModeloExameAnalito,
  LabVet.Repositories.Base;

type
  TModeloExameAnalitoRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TModeloExameAnalito;
    procedure SetReferences(AQuery: TFDQuery; AValue: TModeloExameAnalito);
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TModeloExameAnalito>;
    function ListByModelo(AIdModeloExame: Int64): TObjectList<TModeloExameAnalito>;
    function FindById(AId: Int64): TModeloExameAnalito;
    procedure Insert(AValue: TModeloExameAnalito; AActorId: Int64);
    procedure Update(AValue: TModeloExameAnalito; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TModeloExameAnalitoRepository.FromQuery(
  AQuery: TFDQuery
): TModeloExameAnalito;
begin
  Result := TModeloExameAnalito.Create;
  Result.IdModeloExameAnalito := AQuery.FieldByName('idmodeloexameanalito').AsLargeInt;
  Result.IdModeloExame := AQuery.FieldByName('idmodeloexame').AsLargeInt;
  Result.IdExameAnalito := AQuery.FieldByName('idexameanalito').AsLargeInt;
  Result.DsSecao := AQuery.FieldByName('dssecao').AsString;
  Result.NrExibicao := AQuery.FieldByName('nrexibicao').AsInteger;
  Result.DsRotulo := AQuery.FieldByName('dsrotulo').AsString;
  Result.DsTecnica := AQuery.FieldByName('dstecnica').AsString;
  Result.DsUnidadeMedida := AQuery.FieldByName('dsunidademedida').AsString;
  Result.DsReferencia := AQuery.FieldByName('dsreferencia').AsString;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;
  Result.VrRefMinimo.PossuiValor := not AQuery.FieldByName('vrrefminimo').IsNull;
  Result.VrRefMaximo.PossuiValor := not AQuery.FieldByName('vrrefmaximo').IsNull;
  if Result.VrRefMinimo.PossuiValor then
    Result.VrRefMinimo.Valor := AQuery.FieldByName('vrrefminimo').AsExtended;
  if Result.VrRefMaximo.PossuiValor then
    Result.VrRefMaximo.Valor := AQuery.FieldByName('vrrefmaximo').AsExtended;
end;

procedure TModeloExameAnalitoRepository.SetReferences(
  AQuery: TFDQuery;
  AValue: TModeloExameAnalito
);
begin
  if AValue.VrRefMinimo.PossuiValor then
    AQuery.ParamByName('reference_minimum').AsExtended := AValue.VrRefMinimo.Valor
  else
    AQuery.ParamByName('reference_minimum').Clear;
  if AValue.VrRefMaximo.PossuiValor then
    AQuery.ParamByName('reference_maximum').AsExtended := AValue.VrRefMaximo.Valor
  else
    AQuery.ParamByName('reference_maximum').Clear;
end;

function TModeloExameAnalitoRepository.List(
  AOnlyActive: Boolean
): TObjectList<TModeloExameAnalito>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TModeloExameAnalito>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select * from modeloexameanalitos ' +
      'where (:only_active = false or stativo = true) ' +
      'order by idmodeloexame, nrexibicao';
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

function TModeloExameAnalitoRepository.ListByModelo(
  AIdModeloExame: Int64
): TObjectList<TModeloExameAnalito>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TModeloExameAnalito>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select * from modeloexameanalitos ' +
      'where idmodeloexame = :model_id and stativo = true ' +
      'order by nrexibicao';
    LQuery.ParamByName('model_id').AsLargeInt := AIdModeloExame;
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

function TModeloExameAnalitoRepository.FindById(
  AId: Int64
): TModeloExameAnalito;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select * from modeloexameanalitos where idmodeloexameanalito = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameAnalitoRepository.Insert(AValue: TModeloExameAnalito; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into modeloexameanalitos (' +
      'idmodeloexame, idexameanalito, dssecao, nrexibicao, dsrotulo, dstecnica, ' +
      'dsunidademedida, dsreferencia, vrrefminimo, vrrefmaximo, ' +
      'idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      ':model_id, :exam_analyte_id, nullif(:section, ''''), :display_order, ' +
      'nullif(:label, ''''), nullif(:technique, ''''), nullif(:unit, ''''), ' +
      'nullif(:reference, ''''), :reference_minimum, :reference_maximum, ' +
      'nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idmodeloexameanalito, stativo';
    LQuery.ParamByName('model_id').AsLargeInt := AValue.IdModeloExame;
    LQuery.ParamByName('exam_analyte_id').AsLargeInt := AValue.IdExameAnalito;
    LQuery.ParamByName('section').AsString := AValue.DsSecao;
    LQuery.ParamByName('display_order').AsInteger := AValue.NrExibicao;
    LQuery.ParamByName('label').AsString := AValue.DsRotulo;
    LQuery.ParamByName('technique').AsString := AValue.DsTecnica;
    LQuery.ParamByName('unit').AsString := AValue.DsUnidadeMedida;
    LQuery.ParamByName('reference').AsString := AValue.DsReferencia;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetReferences(LQuery, AValue);
    LQuery.Open;
    AValue.IdModeloExameAnalito := LQuery.FieldByName('idmodeloexameanalito').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameAnalitoRepository.Update(AValue: TModeloExameAnalito; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update modeloexameanalitos set idexameanalito = :exam_analyte_id, ' +
      'dssecao = nullif(:section, ''''), nrexibicao = :display_order, ' +
      'dsrotulo = nullif(:label, ''''), dstecnica = nullif(:technique, ''''), ' +
      'dsunidademedida = nullif(:unit, ''''), dsreferencia = nullif(:reference, ''''), ' +
      'vrrefminimo = :reference_minimum, vrrefmaximo = :reference_maximum, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idmodeloexameanalito = :id and idmodeloexame = :model_id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdModeloExameAnalito;
    LQuery.ParamByName('model_id').AsLargeInt := AValue.IdModeloExame;
    LQuery.ParamByName('exam_analyte_id').AsLargeInt := AValue.IdExameAnalito;
    LQuery.ParamByName('section').AsString := AValue.DsSecao;
    LQuery.ParamByName('display_order').AsInteger := AValue.NrExibicao;
    LQuery.ParamByName('label').AsString := AValue.DsRotulo;
    LQuery.ParamByName('technique').AsString := AValue.DsTecnica;
    LQuery.ParamByName('unit').AsString := AValue.DsUnidadeMedida;
    LQuery.ParamByName('reference').AsString := AValue.DsReferencia;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetReferences(LQuery, AValue);
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Item do modelo não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameAnalitoRepository.SetActive(
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
      'update modeloexameanalitos set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idmodeloexameanalito = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Item do modelo não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
