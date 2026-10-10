unit LabVet.Services.Password;

interface

type
  TPasswordService = class
  public
    class function Hash(const APassword: string): string; static;
    class function Verify(const APassword, AHash: string): Boolean; static;
  end;

implementation

uses
  System.Math, System.NetEncoding, System.SysUtils, Winapi.Windows;

const
  BCRYPT_USE_SYSTEM_PREFERRED_RNG = $00000002;
  BCRYPT_ALG_HANDLE_HMAC_FLAG = $00000008;
  PASSWORD_ITERATIONS = 310000;
  SALT_BYTES = 16;
  HASH_BYTES = 32;

function BCryptOpenAlgorithmProvider(out AHandle: Pointer; AAlgId: PWideChar;
  AImplementation: PWideChar; AFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll';
function BCryptCloseAlgorithmProvider(AHandle: Pointer; AFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll';
function BCryptGenRandom(AHandle: Pointer; ABuffer: PByte; ABufferLength: Cardinal;
  AFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll';
function BCryptDeriveKeyPBKDF2(AHandle: Pointer; APassword: PByte; APasswordLength: Cardinal;
  ASalt: PByte; ASaltLength: Cardinal; AIterations: UInt64; ADerivedKey: PByte;
  ADerivedKeyLength: Cardinal; AFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll';

procedure Derive(const APassword: string; const ASalt: TBytes; out AHash: TBytes);
var
  LHandle: Pointer;
  LPassword: TBytes;
begin
  LPassword := TEncoding.UTF8.GetBytes(APassword);
  if BCryptOpenAlgorithmProvider(LHandle, 'SHA256', nil, BCRYPT_ALG_HANDLE_HMAC_FLAG) <> 0 then
    raise EInvalidOp.Create('Não foi possível preparar o hash de senha.');
  try
    SetLength(AHash, HASH_BYTES);
    if BCryptDeriveKeyPBKDF2(LHandle, @LPassword[0], Length(LPassword), @ASalt[0],
      Length(ASalt), PASSWORD_ITERATIONS, @AHash[0], Length(AHash), 0) <> 0 then
      raise EInvalidOp.Create('Não foi possível calcular o hash de senha.');
  finally
    BCryptCloseAlgorithmProvider(LHandle, 0);
  end;
end;

class function TPasswordService.Hash(const APassword: string): string;
var
  LSalt, LHash: TBytes;
begin
  if APassword.IsEmpty then
    raise EArgumentException.Create('A senha é obrigatória.');
  SetLength(LSalt, SALT_BYTES);
  if BCryptGenRandom(nil, @LSalt[0], Length(LSalt), BCRYPT_USE_SYSTEM_PREFERRED_RNG) <> 0 then
    raise EInvalidOp.Create('Não foi possível gerar o salt da senha.');
  Derive(APassword, LSalt, LHash);
  Result := Format('pbkdf2-sha256$%d$%s$%s', [PASSWORD_ITERATIONS,
    TNetEncoding.Base64.EncodeBytesToString(LSalt),
    TNetEncoding.Base64.EncodeBytesToString(LHash)]);
end;

class function TPasswordService.Verify(const APassword, AHash: string): Boolean;
var
  LParts: TArray<string>;
  LSalt, LExpected, LActual: TBytes;
  I, LDifference: Integer;
begin
  Result := False;
  LParts := AHash.Split(['$']);
  if (Length(LParts) <> 4) or (LParts[0] <> 'pbkdf2-sha256') or
    (StrToIntDef(LParts[1], 0) <> PASSWORD_ITERATIONS) then Exit;
  try
    LSalt := TNetEncoding.Base64.DecodeStringToBytes(LParts[2]);
    LExpected := TNetEncoding.Base64.DecodeStringToBytes(LParts[3]);
    if (Length(LSalt) <> SALT_BYTES) or (Length(LExpected) <> HASH_BYTES) then Exit;
    Derive(APassword, LSalt, LActual);
    LDifference := Length(LExpected) xor Length(LActual);
    for I := 0 to Min(High(LExpected), High(LActual)) do
      LDifference := LDifference or (LExpected[I] xor LActual[I]);
    Result := LDifference = 0;
  except
    Result := False;
  end;
end;

end.
