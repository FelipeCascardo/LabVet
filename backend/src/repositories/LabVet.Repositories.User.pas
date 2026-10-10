unit LabVet.Repositories.User;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  LabVet.Models.User,
  LabVet.Repositories.Base;

type
  TUserRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TAppUser;
  public
    function IsEmpty: Boolean;
    function List: TObjectList<TAppUser>;
    function FindById(AId: Int64): TAppUser;
    function FindByEmail(const AEmail: string): TAppUser;
    procedure Insert(AUser: TAppUser);
    procedure Update(AUser: TAppUser);
    procedure SetActive(AId: Int64; AActive: Boolean);
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Param,
  Data.DB;

function TUserRepository.FromQuery(AQuery: TFDQuery): TAppUser;
begin
  Result := TAppUser.Create;
  Result.Id := AQuery.FieldByName('user_id').AsLargeInt;
  Result.FullName := AQuery.FieldByName('full_name').AsString;
  Result.Email := AQuery.FieldByName('email').AsString;
  if AQuery.FindField('password_hash') <> nil then
    Result.PasswordHash := AQuery.FieldByName('password_hash').AsString;
  Result.SecurityVersion := AQuery.FieldByName('security_version').AsInteger;
  Result.CreatedAt := AQuery.FieldByName('created_at').AsDateTime;
  Result.UpdatedAt := AQuery.FieldByName('updated_at').AsDateTime;
  Result.IsActive := AQuery.FieldByName('is_active').AsBoolean;
end;

function TUserRepository.IsEmpty: Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select not exists (select 1 from app_users) as is_empty';
    LQuery.Open;
    Result := LQuery.FieldByName('is_empty').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

function TUserRepository.List: TObjectList<TAppUser>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TAppUser>.Create(True);
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select user_id, full_name, email, security_version, created_at, updated_at, is_active from app_users order by full_name';
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

function TUserRepository.FindById(AId: Int64): TAppUser;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select user_id, full_name, email, password_hash, security_version, created_at, updated_at, is_active from app_users where user_id = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TUserRepository.FindByEmail(const AEmail: string): TAppUser;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select user_id, full_name, email, password_hash, security_version, created_at, updated_at, is_active from app_users where lower(email) = lower(:email)';
    LQuery.ParamByName('email').AsString := AEmail;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TUserRepository.Insert(AUser: TAppUser);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'insert into app_users (full_name, email, password_hash) values (:name, lower(:email), :hash) returning user_id, security_version, created_at, updated_at, is_active';
    LQuery.ParamByName('name').AsString := AUser.FullName;
    LQuery.ParamByName('email').AsString := AUser.Email;
    LQuery.ParamByName('hash').AsString := AUser.PasswordHash;
    LQuery.Open;
    AUser.Id := LQuery.FieldByName('user_id').AsLargeInt;
    AUser.SecurityVersion := LQuery.FieldByName('security_version').AsInteger;
    AUser.CreatedAt := LQuery.FieldByName('created_at').AsDateTime;
    AUser.UpdatedAt := LQuery.FieldByName('updated_at').AsDateTime;
    AUser.IsActive := LQuery.FieldByName('is_active').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TUserRepository.Update(AUser: TAppUser);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'update app_users set full_name = :name, email = lower(:email), password_hash = :hash, security_version = security_version + case when password_hash is distinct from :hash then 1 else 0 end where user_id = :id and is_active = true returning security_version, created_at, updated_at, is_active';
    LQuery.ParamByName('name').AsString := AUser.FullName;
    LQuery.ParamByName('email').AsString := AUser.Email;
    LQuery.ParamByName('hash').AsString := AUser.PasswordHash;
    LQuery.ParamByName('id').AsLargeInt := AUser.Id;
    LQuery.Open;
    if LQuery.IsEmpty then
      raise EInvalidOp.Create('Usuário não encontrado ou inativo.');
    AUser.SecurityVersion := LQuery.FieldByName('security_version').AsInteger;
    AUser.CreatedAt := LQuery.FieldByName('created_at').AsDateTime;
    AUser.UpdatedAt := LQuery.FieldByName('updated_at').AsDateTime;
    AUser.IsActive := LQuery.FieldByName('is_active').AsBoolean;
  finally
    LQuery.Free;
  end;
end;

procedure TUserRepository.SetActive(AId: Int64; AActive: Boolean);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'update app_users set is_active = :active where user_id = :id and is_active is distinct from :active';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ParamByName('active').AsBoolean := AActive;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then
      raise EInvalidOp.Create('Usuário não encontrado ou já está nesse estado.');
  finally
    LQuery.Free;
  end;
end;

end.
