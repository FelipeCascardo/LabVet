unit LabVet.Repositories.Session;

interface

uses FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB, LabVet.Repositories.Base;

type
  TUserSession = class
  public
    Id: Int64;
    UserId: Int64;
    RefreshHash: string;
    ExpiresAt: TDateTime;
    RevokedAt: TDateTime;
    SecurityVersion: Integer;
  end;

  TSessionRepository = class(TBaseRepository)
  private
    function FromQuery(AQuery: TFDQuery): TUserSession;
  public
    function CreateSession(AUserId: Int64; const ARefreshHash: string; AExpiresAt: TDateTime; ASecurityVersion: Integer): TUserSession;
    function FindById(AId: Int64): TUserSession;
    function FindByRefreshHash(const AHash: string): TUserSession;
    procedure Rotate(AId: Int64; const AHash: string; AExpiresAt: TDateTime);
    procedure Revoke(AId: Int64);
    procedure RevokeByUser(AUserId: Int64);
  end;

implementation

uses System.SysUtils;

function TSessionRepository.FromQuery(AQuery: TFDQuery): TUserSession;
begin
  Result := TUserSession.Create;
  Result.Id := AQuery.FieldByName('session_id').AsLargeInt;
  Result.UserId := AQuery.FieldByName('user_id').AsLargeInt;
  Result.RefreshHash := AQuery.FieldByName('refresh_token_hash').AsString;
  Result.ExpiresAt := AQuery.FieldByName('expires_at').AsDateTime;
  if not AQuery.FieldByName('revoked_at').IsNull then
    Result.RevokedAt := AQuery.FieldByName('revoked_at').AsDateTime;
  Result.SecurityVersion := AQuery.FieldByName('security_version').AsInteger;
end;

function TSessionRepository.CreateSession(AUserId: Int64; const ARefreshHash: string; AExpiresAt: TDateTime; ASecurityVersion: Integer): TUserSession;
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'insert into user_sessions (user_id, refresh_token_hash, expires_at, security_version) values (:user, :hash, :expires, :version) returning *';
    LQuery.ParamByName('user').AsLargeInt := AUserId;
    LQuery.ParamByName('hash').AsString := ARefreshHash;
    LQuery.ParamByName('expires').AsDateTime := AExpiresAt;
    LQuery.ParamByName('version').AsInteger := ASecurityVersion;
    LQuery.Open;
    Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TSessionRepository.FindById(AId: Int64): TUserSession;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select * from user_sessions where session_id = :id';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TSessionRepository.FindByRefreshHash(const AHash: string): TUserSession;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'select * from user_sessions where refresh_token_hash = :hash and revoked_at is null';
    LQuery.ParamByName('hash').AsString := AHash;
    LQuery.Open;
    if not LQuery.IsEmpty then Result := FromQuery(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TSessionRepository.Rotate(AId: Int64; const AHash: string; AExpiresAt: TDateTime);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'update user_sessions set refresh_token_hash = :hash, expires_at = :expires where session_id = :id and revoked_at is null';
    LQuery.ParamByName('hash').AsString := AHash;
    LQuery.ParamByName('expires').AsDateTime := AExpiresAt;
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ExecSQL;
    if LQuery.RowsAffected <> 1 then raise EInvalidOp.Create('Sessão inválida.');
  finally
    LQuery.Free;
  end;
end;

procedure TSessionRepository.Revoke(AId: Int64);
var LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'update user_sessions set revoked_at = current_timestamp where session_id = :id and revoked_at is null';
    LQuery.ParamByName('id').AsLargeInt := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TSessionRepository.RevokeByUser(AUserId: Int64);
var LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'update user_sessions set revoked_at = current_timestamp where user_id = :user and revoked_at is null';
    LQuery.ParamByName('user').AsLargeInt := AUserId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
