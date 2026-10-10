unit LabVet.Repositories.Audit;

interface

uses System.JSON, LabVet.Repositories.Base;

type
  TAuditRepository = class(TBaseRepository)
  public
    procedure RegisterEvent(AActorId: Int64; const AEventType, AResourceType, AResourceId, ARequestId: string; ADetails: TJSONObject);
  end;

implementation

uses FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB;

procedure TAuditRepository.RegisterEvent(AActorId: Int64; const AEventType, AResourceType, AResourceId, ARequestId: string; ADetails: TJSONObject);
var
  LQuery: TFDQuery;
begin
  LQuery := NewQuery;
  try
    LQuery.SQL.Text := 'insert into audit_events (actor_user_id, event_type, resource_type, resource_id, request_id, details) values (nullif(:actor, 0), :event, :resource, nullif(:resource_id, ''''), nullif(:request_id, ''''), cast(:details as jsonb))';
    LQuery.ParamByName('actor').AsLargeInt := AActorId;
    LQuery.ParamByName('event').AsString := AEventType;
    LQuery.ParamByName('resource').AsString := AResourceType;
    LQuery.ParamByName('resource_id').AsString := AResourceId;
    LQuery.ParamByName('request_id').AsString := ARequestId;
    LQuery.ParamByName('details').AsString := ADetails.ToJSON;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
