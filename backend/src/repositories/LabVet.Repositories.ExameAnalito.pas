unit LabVet.Repositories.ExameAnalito;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.ExameAnalito,
  LabVet.Repositories.Base;

type
  TExameAnalitoRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TExameAnalito;
  public
    function List(AOnlyActive: Boolean = True): TObjectList<TExameAnalito>;
    function FindById(AId: Int64): TExameAnalito;
    function FindByExameAnalito(AExameId, AAnalitoId: Int64): TExameAnalito;
    procedure Insert(AValue: TExameAnalito; AActorId: Int64);
    procedure Update(AValue: TExameAnalito; AActorId: Int64);
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

function TExameAnalitoRepository.FromQuery(
  AQuery: TFDQuery
): TExameAnalito;
begin
  Result := TExameAnalito.Create;
  Result.IdExameAnalito := AQuery.FieldByName('idexameanalito').AsLargeInt;
  Result.IdExame := AQuery.FieldByName('idexame').AsLargeInt;
  Result.IdAnalito := AQuery.FieldByName('idanalito').AsLargeInt;
  Result.StAtivo := AQuery.FieldByName('stativo').AsBoolean;
end;

function TExameAnalitoRepository.List(
  AOnlyActive: Boolean
): TObjectList<TExameAnalito>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TExameAnalito>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexameanalito, idexame, idanalito, stativo ' +
      'from exameanalitos ' +
      'where (:only_active = false or stativo = true) ' +
      'order by idexame, idanalito';
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

function TExameAnalitoRepository.FindById(AId: Int64): TExameAnalito;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexameanalito, idexame, idanalito, stativo ' +
      'from exameanalitos where idexameanalito = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TExameAnalitoRepository.FindByExameAnalito(
  AExameId: Int64;
  AAnalitoId: Int64
): TExameAnalito;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'select idexameanalito, idexame, idanalito, stativo ' +
      'from exameanalitos ' +
      'where idexame = :exam_id and idanalito = :analyte_id';
    LQuery.ParamByName('exam_id').AsLargeInt := AExameId;
    LQuery.ParamByName('analyte_id').AsLargeInt := AAnalitoId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TExameAnalitoRepository.Insert(
  AValue: TExameAnalito;
  AActorId: Int64
);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'insert into exameanalitos (' +
      '  idexame, idanalito, idusuarioinclusao, idusuarioalteracao' +
      ') values (' +
      '  :exam_id, :analyte_id, nullif(:actor, 0), nullif(:actor, 0)' +
      ') returning idexameanalito, stativo';
    LQuery.ParamByName('exam_id').AsLargeInt := AValue.IdExame;
    LQuery.ParamByName('analyte_id').AsLargeInt := AValue.IdAnalito;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.Open;
    AValue.IdExameAnalito := LQuery.FieldByName('idexameanalito').AsLargeInt;
    AValue.StAtivo := LQuery.FieldByName('stativo').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TExameAnalitoRepository.Update(
  AValue: TExameAnalito;
  AActorId: Int64
);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text :=
      'update exameanalitos set ' +
      'idexame = :exam_id, ' +
      'idanalito = :analyte_id, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexameanalito = :id and stativo = true';
    LQuery.ParamByName('id').AsLargeInt := AValue.IdExameAnalito;
    LQuery.ParamByName('exam_id').AsLargeInt := AValue.IdExame;
    LQuery.ParamByName('analyte_id').AsLargeInt := AValue.IdAnalito;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Vínculo não encontrado ou inativo.');
  finally
    LQuery.Free;
  end;
end;

procedure TExameAnalitoRepository.SetActive(
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
      'update exameanalitos set stativo = :active, ' +
      'idusuarioalteracao = nullif(:actor, 0) ' +
      'where idexameanalito = :id and stativo is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Vínculo não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
