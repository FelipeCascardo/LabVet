unit LabVet.Repositories.ExameCategoria;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.ExameCategoria,
  LabVet.Repositories.Base;

type
  TExameCategoriaRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TExameCategoria;
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TExameCategoria>;
    function FindById(AId: Int64): TExameCategoria;
    function FindByName(const AName: string): TExameCategoria;
    procedure Insert(AValue: TExameCategoria; AActorId: Int64);
    procedure Update(AValue: TExameCategoria; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TExameCategoriaRepository.FromQuery(AQuery: TFDQuery): TExameCategoria;
begin
  Result := TExameCategoria.Create;
  Result.IdExameCategoria := AQuery.FieldByName('idexamecategoria').AsLargeInt;
  Result.NmCategoria := AQuery.FieldByName('nmcategoria').AsString;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;
end;

function TExameCategoriaRepository.List(
  AOnlyActive: Boolean
): TObjectList<TExameCategoria>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TExameCategoria>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexamecategoria, nmcategoria, stativo ' +
      'from examecategorias ' +
      'where (:only_active = false or stativo = true) ' +
      'order by nmcategoria';
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

function TExameCategoriaRepository.FindById(AId: Int64): TExameCategoria;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexamecategoria, nmcategoria, stativo ' +
      'from examecategorias where idexamecategoria = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TExameCategoriaRepository.FindByName(
  const AName: string
): TExameCategoria;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexamecategoria, nmcategoria, stativo ' +
      'from examecategorias where lower(nmcategoria) = lower(:name)';
    LQuery.ParamByName('name').AsString := AName;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TExameCategoriaRepository.Insert(
  AValue: TExameCategoria;
  AActorId: Int64
);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into examecategorias ' +
      '  (nmcategoria, idusuarioinclusao, idusuarioalteracao) ' +
      'values (:name, nullif(:actor, 0), nullif(:actor, 0)) ' +
      'returning idexamecategoria, stativo';
    LQuery.ParamByName('name').AsString := AValue.NmCategoria;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.Open;
    AValue.IdExameCategoria := LQuery.FieldByName('idexamecategoria').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TExameCategoriaRepository.Update(
  AValue: TExameCategoria;
  AActorId: Int64
);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update examecategorias set nmcategoria = :name, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexamecategoria = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdExameCategoria;
    LQuery.ParamByName('name').AsString := AValue.NmCategoria;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Categoria não encontrada ou inativa.');
  finally
    LQuery.Free;
  end;
end;

procedure TExameCategoriaRepository.SetActive(
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
      'update examecategorias set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexamecategoria = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Categoria não encontrada ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
