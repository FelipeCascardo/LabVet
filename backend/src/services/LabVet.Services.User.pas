unit LabVet.Services.User;

interface

uses System.JSON, System.SysUtils, LabVet.Models.User;

type
  EUserValidation = class(Exception);
  EUserNotFound = class(Exception);
  EUserEmailDuplicate = class(Exception);

  TUserService = class
  private
    procedure Validate(const AName, AEmail, APassword: string; APasswordRequired: Boolean);
  public
    function List: TJSONArray;
    function GetById(AId: Int64): TAppUser;
    function CreateUser(AInput: TUserInput; AActorId: Int64 = 0): TAppUser;
    function CreateInitial(AInput: TUserInput): TAppUser;
    function Update(AId: Int64; AInput: TUserInput; AActorId: Int64): TAppUser;
    procedure SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
  end;

implementation

uses
  System.Generics.Collections,
  LabVet.Repositories.Session, LabVet.Repositories.User,
  LabVet.Services.Audit, LabVet.Services.Password;

procedure TUserService.Validate(const AName, AEmail, APassword: string;
  APasswordRequired: Boolean);
begin
  if AName.Trim.IsEmpty or (Length(AName.Trim) > 150) then
    raise EUserValidation.Create('Informe um nome de até 150 caracteres.');
  if AEmail.Trim.IsEmpty or not AEmail.Contains('@') or (Length(AEmail.Trim) > 150) then
    raise EUserValidation.Create('Informe um e-mail válido.');
  if APasswordRequired and (Length(APassword) < 12) then
    raise EUserValidation.Create('A senha deve ter ao menos 12 caracteres.');
  if (not APasswordRequired) and (not APassword.IsEmpty) and (Length(APassword) < 12) then
    raise EUserValidation.Create('A senha deve ter ao menos 12 caracteres.');
end;

function TUserService.List: TJSONArray;
var
  LRepository: TUserRepository;
  LUsers: TObjectList<TAppUser>;
  LUser: TAppUser;
begin
  Result := TJSONArray.Create;
  LRepository := TUserRepository.Create;
  try
    LUsers := LRepository.List;
    try
      for LUser in LUsers do Result.AddElement(LUser.ToJSON);
    finally
      LUsers.Free;
    end;
  finally
    LRepository.Free;
  end;
end;

function TUserService.GetById(AId: Int64): TAppUser;
var
  LRepository: TUserRepository;
begin
  LRepository := TUserRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EUserNotFound.Create('Usuário não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TUserService.CreateUser(AInput: TUserInput; AActorId: Int64): TAppUser;
var
  LRepository: TUserRepository;
  LExisting: TAppUser;
begin
  Validate(AInput.FullName, AInput.Email, AInput.Password, True);
  LRepository := TUserRepository.Create;
  try
    LExisting := LRepository.FindByEmail(AInput.Email.Trim);
    try
      if Assigned(LExisting) then raise EUserEmailDuplicate.Create('Já existe um usuário com este e-mail.');
    finally
      LExisting.Free;
    end;
    Result := TAppUser.Create;
    Result.FullName := AInput.FullName.Trim;
    Result.Email := AInput.Email.Trim.ToLower;
    Result.PasswordHash := TPasswordService.Hash(AInput.Password);
    LRepository.Insert(Result);
    TAuditService.RegisterEvent(AActorId, 'user.created', 'app_user', Result.Id.ToString, '');
  finally
    LRepository.Free;
  end;
end;

function TUserService.CreateInitial(AInput: TUserInput): TAppUser;
var
  LRepository: TUserRepository;
begin
  LRepository := TUserRepository.Create;
  try
    if not LRepository.IsEmpty then
      raise EUserValidation.Create('A configuração inicial já foi concluída.');
  finally
    LRepository.Free;
  end;
  Result := CreateUser(AInput);
end;

function TUserService.Update(AId: Int64; AInput: TUserInput; AActorId: Int64): TAppUser;
var
  LRepository: TUserRepository;
  LExisting: TAppUser;
  LSessions: TSessionRepository;
begin
  Validate(AInput.FullName, AInput.Email, AInput.Password, False);
  LRepository := TUserRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.IsActive) then
    begin
      Result.Free;
      raise EUserNotFound.Create('Usuário não encontrado.');
    end;
    LExisting := LRepository.FindByEmail(AInput.Email.Trim);
    try
      if Assigned(LExisting) and (LExisting.Id <> AId) then raise EUserEmailDuplicate.Create('Já existe um usuário com este e-mail.');
    finally
      LExisting.Free;
    end;
    Result.FullName := AInput.FullName.Trim;
    Result.Email := AInput.Email.Trim.ToLower;
    if not AInput.Password.IsEmpty then Result.PasswordHash := TPasswordService.Hash(AInput.Password);
    LRepository.Update(Result);
    if not AInput.Password.IsEmpty then
    begin
      LSessions := TSessionRepository.Create;
      try LSessions.RevokeByUser(AId); finally LSessions.Free; end;
    end;
    TAuditService.RegisterEvent(AActorId, 'user.updated', 'app_user', AId.ToString, '');
  finally
    LRepository.Free;
  end;
end;

procedure TUserService.SetActive(AId: Int64; AActive: Boolean; AActorId: Int64);
var
  LRepository: TUserRepository;
  LSessions: TSessionRepository;
  LEventType: string;
begin
  LRepository := TUserRepository.Create;
  try
    try
      LRepository.SetActive(AId, AActive);
    except
      on E: EInvalidOp do raise EUserNotFound.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
  if not AActive then
  begin
    LSessions := TSessionRepository.Create;
    try LSessions.RevokeByUser(AId); finally LSessions.Free; end;
  end;
  if AActive then
    LEventType := 'user.reactivated'
  else
    LEventType := 'user.deactivated';
  TAuditService.RegisterEvent(AActorId, LEventType, 'app_user', AId.ToString, '');
end;

end.
