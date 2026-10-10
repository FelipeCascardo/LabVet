unit LabVet.Services.Audit;

interface

uses System.JSON;

type
  TAuditService = class
  public
    class procedure RegisterEvent(AActorId: Int64; const AEventType, AResourceType,
      AResourceId, ARequestId: string; ADetails: TJSONObject = nil); static;
  end;

implementation

uses LabVet.Repositories.Audit;

class procedure TAuditService.RegisterEvent(AActorId: Int64; const AEventType,
  AResourceType, AResourceId, ARequestId: string; ADetails: TJSONObject);
var
  LRepository: TAuditRepository;
  LPayload: TJSONObject;
begin
  if Assigned(ADetails) then
    LPayload := ADetails
  else
    LPayload := TJSONObject.Create;
  try
    LRepository := TAuditRepository.Create;
    try
      LRepository.RegisterEvent(AActorId, AEventType, AResourceType, AResourceId,
        ARequestId, LPayload);
    finally
      LRepository.Free;
    end;
  finally
    if not Assigned(ADetails) then
      LPayload.Free;
  end;
end;

end.
