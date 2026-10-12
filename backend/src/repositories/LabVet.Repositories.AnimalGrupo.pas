unit LabVet.Repositories.AnimalGrupo;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.AnimalGrupo,
  LabVet.Repositories.Base;

type
  TAnimalGrupoRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TAnimalGrupo;
    procedure SetParent(AQuery: TFDQuery; AValue: TAnimalGrupo);
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TAnimalGrupo>;
    function FindById(AId: Int64): TAnimalGrupo;
    procedure Insert(AValue: TAnimalGrupo; AActorId: Int64);
    procedure Update(AValue: TAnimalGrupo; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TAnimalGrupoRepository.FromQuery(AQuery: TFDQuery): TAnimalGrupo;
begin
  Result := TAnimalGrupo.Create;
  Result.IdAnimalGrupo := AQuery.FieldByName('idanimalgrupo').AsLargeInt;
  Result.NmAnimalGrupo := AQuery.FieldByName('nmtipoanimal').AsString;
  Result.DsDescricao := AQuery.FieldByName('dsdescricao').AsString;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;

  Result.IdAnimalGrupoPai.PossuiValor :=
    not AQuery.FieldByName('idanimalgrupopai').IsNull;
  if Result.IdAnimalGrupoPai.PossuiValor then
    Result.IdAnimalGrupoPai.Valor :=
      AQuery.FieldByName('idanimalgrupopai').AsLargeInt;
end;

procedure TAnimalGrupoRepository.SetParent(
  AQuery: TFDQuery;
  AValue: TAnimalGrupo
);
begin
  if AValue.IdAnimalGrupoPai.PossuiValor then
    AQuery.ParamByName('parent_id').AsLargeInt := AValue.IdAnimalGrupoPai.Valor
  else
    AQuery.ParamByName('parent_id').Clear;
end;

function TAnimalGrupoRepository.List(
  AOnlyActive: Boolean
): TObjectList<TAnimalGrupo>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TAnimalGrupo>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idanimalgrupo, idanimalgrupopai, nmtipoanimal, dsdescricao, stativo ' +
      'from animalgrupos ' +
      'where (:only_active = false or stativo = true) ' +
      'order by nmtipoanimal';
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

function TAnimalGrupoRepository.FindById(AId: Int64): TAnimalGrupo;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idanimalgrupo, idanimalgrupopai, nmtipoanimal, dsdescricao, stativo ' +
      'from animalgrupos where idanimalgrupo = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TAnimalGrupoRepository.Insert(AValue: TAnimalGrupo; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into animalgrupos (' +
      '  idanimalgrupopai, nmtipoanimal, dsdescricao, ' +
      '  idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      '  :parent_id, :name, nullif(:description, ''''), ' +
      '  nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idanimalgrupo, stativo';
    LQuery.ParamByName('name').AsString := AValue.NmAnimalGrupo;
    LQuery.ParamByName('description').AsString := AValue.DsDescricao;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetParent(LQuery, AValue);
    LQuery.Open;
    AValue.IdAnimalGrupo := LQuery.FieldByName('idanimalgrupo').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TAnimalGrupoRepository.Update(AValue: TAnimalGrupo; AActorId: Int64);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update animalgrupos set ' +
      '  idanimalgrupopai = :parent_id, nmtipoanimal = :name, ' +
      '  dsdescricao = nullif(:description, ''''), ' +
      '  idusuarioalteracao = nullif(:actor, 0) ' +
      'where idanimalgrupo = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdAnimalGrupo;
    LQuery.ParamByName('name').AsString := AValue.NmAnimalGrupo;
    LQuery.ParamByName('description').AsString := AValue.DsDescricao;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    SetParent(LQuery, AValue);
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Grupo de animais não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TAnimalGrupoRepository.SetActive(
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
      'update animalgrupos set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idanimalgrupo = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Grupo de animais não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
