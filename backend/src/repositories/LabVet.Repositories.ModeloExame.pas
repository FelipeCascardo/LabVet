unit LabVet.Repositories.ModeloExame;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.ModeloExame,
  LabVet.Repositories.Base;

type
  TModeloExameRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TModeloExame;
    procedure SetOptionalIds(AQuery: TFDQuery; AValue: TModeloExame);
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TModeloExame>;
    function FindById(AId: Int64): TModeloExame;
    function FindByCode(const ACode: string): TModeloExame;
    procedure Insert(AValue: TModeloExame; AActorId: Int64);
    procedure Update(AValue: TModeloExame; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TModeloExameRepository.FromQuery(AQuery: TFDQuery): TModeloExame;
begin
  Result := TModeloExame.Create;
  Result.IdModeloExame := AQuery.FieldByName('idmodeloexame').AsLargeInt;
  Result.CdModeloLaudo := AQuery.FieldByName('cdmodelolaudo').AsString;
  Result.NmModeloLaudo := AQuery.FieldByName('nmmodelolaudo').AsString;
  Result.DsFaixaIdade := AQuery.FieldByName('dsfaixaidade').AsString;
  Result.NmArquivoOrigem := AQuery.FieldByName('nmarquivoorigem').AsString;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;
  Result.IdExame.PossuiValor := not AQuery.FieldByName('idexame').IsNull;
  Result.IdAnimalGrupo.PossuiValor := not AQuery.FieldByName('idanimalgrupo').IsNull;
  if Result.IdExame.PossuiValor then
    Result.IdExame.Valor := AQuery.FieldByName('idexame').AsLargeInt;
  if Result.IdAnimalGrupo.PossuiValor then
    Result.IdAnimalGrupo.Valor := AQuery.FieldByName('idanimalgrupo').AsLargeInt;
end;

procedure TModeloExameRepository.SetOptionalIds(AQuery: TFDQuery; AValue: TModeloExame);
begin
  if AValue.IdExame.PossuiValor then
    AQuery.ParamByName('exam_id').AsLargeInt := AValue.IdExame.Valor
  else
    AQuery.ParamByName('exam_id').Clear;
  if AValue.IdAnimalGrupo.PossuiValor then
    AQuery.ParamByName('animal_group_id').AsLargeInt := AValue.IdAnimalGrupo.Valor
  else
    AQuery.ParamByName('animal_group_id').Clear;
end;

function TModeloExameRepository.List(AOnlyActive: Boolean): TObjectList<TModeloExame>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TModeloExame>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idmodeloexame, idexame, idanimalgrupo, cdmodelolaudo, ' +
      'nmmodelolaudo, dsfaixaidade, nmarquivoorigem, stativo ' +
      'from modeloexames where (:only_active = false or stativo = true) ' +
      'order by nmmodelolaudo';
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

function TModeloExameRepository.FindById(AId: Int64): TModeloExame;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idmodeloexame, idexame, idanimalgrupo, cdmodelolaudo, ' +
      'nmmodelolaudo, dsfaixaidade, nmarquivoorigem, stativo ' +
      'from modeloexames where idmodeloexame = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TModeloExameRepository.FindByCode(const ACode: string): TModeloExame;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idmodeloexame, idexame, idanimalgrupo, cdmodelolaudo, ' +
      'nmmodelolaudo, dsfaixaidade, nmarquivoorigem, stativo ' +
      'from modeloexames where lower(cdmodelolaudo) = lower(:code)';
    LQuery.ParamByName('code').AsString := ACode;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameRepository.Insert(AValue: TModeloExame; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into modeloexames (' +
      '  idexame, idanimalgrupo, cdmodelolaudo, nmmodelolaudo, dsfaixaidade, ' +
      '  nmarquivoorigem, idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      '  :exam_id, :animal_group_id, :code, :name, nullif(:age_range, ''''), ' +
      '  nullif(:source_file, ''''), nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idmodeloexame, stativo';
    LQuery.ParamByName('code').AsString := AValue.CdModeloLaudo;
    LQuery.ParamByName('name').AsString := AValue.NmModeloLaudo;
    LQuery.ParamByName('age_range').AsString := AValue.DsFaixaIdade;
    LQuery.ParamByName('source_file').AsString := AValue.NmArquivoOrigem;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetOptionalIds(LQuery, AValue);
    LQuery.Open;
    AValue.IdModeloExame := LQuery.FieldByName('idmodeloexame').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameRepository.Update(AValue: TModeloExame; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update modeloexames set ' +
      '  idexame = :exam_id, idanimalgrupo = :animal_group_id, ' +
      '  cdmodelolaudo = :code, nmmodelolaudo = :name, ' +
      '  dsfaixaidade = nullif(:age_range, ''''), ' +
      '  nmarquivoorigem = nullif(:source_file, ''''), ' +
      '  idusuarioalteracao = nullif(:actor, 0) ' +
      'where idmodeloexame = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdModeloExame;
    LQuery.ParamByName('code').AsString := AValue.CdModeloLaudo;
    LQuery.ParamByName('name').AsString := AValue.NmModeloLaudo;
    LQuery.ParamByName('age_range').AsString := AValue.DsFaixaIdade;
    LQuery.ParamByName('source_file').AsString := AValue.NmArquivoOrigem;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetOptionalIds(LQuery, AValue);
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Modelo de exame não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TModeloExameRepository.SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update modeloexames set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idmodeloexame = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Modelo de exame não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
