unit LabVet.Controllers.User;

interface

procedure Register;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse,
  Horse.Commons,
  Horse.Exception,
  LabVet.Middlewares.Auth,
  LabVet.Models.User,
  LabVet.Services.User;

function RequestJSON(ARequest: THorseRequest): TJSONObject;
var
  LValue: TJSONValue;
begin
  LValue := TJSONObject.ParseJSONValue(ARequest.Body);
  if not (LValue is TJSONObject) then
  begin
    LValue.Free;
    raise EArgumentException.Create(
      'O corpo da requisição deve ser um JSON válido.'
    );
  end;
  Result := TJSONObject(LValue);
end;

function RequestId(ARequest: THorseRequest): Int64;
begin
  if not TryStrToInt64(ARequest.Params['id'], Result) or (Result <= 0) then
    raise EUserValidation.Create('Identificador de usuário inválido.');
end;

procedure SendJSON(
  AResponse: THorseResponse;
  AJSON: TJSONValue;
  AStatus: THTTPStatus = THTTPStatus.Ok
);
begin
  try
    AResponse
      .ContentType('application/json; charset=utf-8')
      .Status(AStatus)
      .Send(AJSON.ToJSON);
  finally
    AJSON.Free;
  end;
end;

procedure HandleError(AException: Exception);
begin
  if (AException is EUserValidation) or
    (AException is EArgumentException) then
    raise EHorseException.New
      .Status(THTTPStatus.BadRequest)
      .Error(AException.Message);

  if AException is EUserNotFound then
    raise EHorseException.New
      .Status(THTTPStatus.NotFound)
      .Error(AException.Message);

  if AException is EUserEmailDuplicate then
    raise EHorseException.New
      .Status(THTTPStatus.Conflict)
      .Error(AException.Message);

  raise EHorseException.New
    .Status(THTTPStatus.InternalServerError)
    .Error('Não foi possível processar a solicitação.');
end;

procedure List(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
var
  LResponse: TJSONArray;
  LService: TUserService;
begin
  try
    LService := TUserService.Create;
    try
      LResponse := LService.List;
      SendJSON(AResponse, LResponse);
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Get(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
var
  LService: TUserService;
  LUser: TAppUser;
begin
  try
    LService := TUserService.Create;
    try
      LUser := LService.GetById(RequestId(ARequest));
      try
        SendJSON(AResponse, LUser.ToJSON);
      finally
        LUser.Free;
      end;
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Save(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc;
  AUpdate: Boolean
);
var
  LInput: TUserInput;
  LJSON: TJSONObject;
  LService: TUserService;
  LUser: TAppUser;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TUserInput.FromJSON(LJSON);
      try
        LService := TUserService.Create;
        try
          if AUpdate then
            LUser := LService.Update(
              RequestId(ARequest),
              LInput,
              CurrentUserId(ARequest)
            )
          else
            LUser := LService.CreateUser(LInput, CurrentUserId(ARequest));
          try
            if AUpdate then
              SendJSON(AResponse, LUser.ToJSON)
            else
              SendJSON(AResponse, LUser.ToJSON, THTTPStatus.Created);
          finally
            LUser.Free;
          end;
        finally
          LService.Free;
        end;
      finally
        LInput.Free;
      end;
    finally
      LJSON.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Create(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  Save(ARequest, AResponse, ANext, False);
end;

procedure CreateInitial(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
var
  LInput: TUserInput;
  LJSON: TJSONObject;
  LService: TUserService;
  LUser: TAppUser;
begin
  try
    LJSON := RequestJSON(ARequest);
    try
      LInput := TUserInput.FromJSON(LJSON);
      try
        LService := TUserService.Create;
        try
          LUser := LService.CreateInitial(LInput);
          try
            SendJSON(AResponse, LUser.ToJSON, THTTPStatus.Created);
          finally
            LUser.Free;
          end;
        finally
          LService.Free;
        end;
      finally
        LInput.Free;
      end;
    finally
      LJSON.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Update(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  Save(ARequest, AResponse, ANext, True);
end;

procedure SetActive(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc;
  AActive: Boolean
);
var
  LService: TUserService;
begin
  try
    LService := TUserService.Create;
    try
      LService.SetActive(
        RequestId(ARequest),
        AActive,
        CurrentUserId(ARequest)
      );
      AResponse.Status(THTTPStatus.NoContent).Send('');
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      HandleError(E);
  end;
end;

procedure Deactivate(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  SetActive(ARequest, AResponse, ANext, False);
end;

procedure Reactivate(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TProc
);
begin
  SetActive(ARequest, AResponse, ANext, True);
end;

procedure Register;
begin
  THorse.Post('/api/v1/setup/primeiro-usuario', CreateInitial);
  THorse.Get('/api/v1/usuarios', List);
  THorse.Get('/api/v1/usuarios/:id', Get);
  THorse.Post('/api/v1/usuarios', Create);
  THorse.Put('/api/v1/usuarios/:id', Update);
  THorse.Delete('/api/v1/usuarios/:id', Deactivate);
  THorse.Post('/api/v1/usuarios/:id/reativar', Reactivate);
end;

end.
