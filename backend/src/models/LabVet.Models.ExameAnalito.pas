unit LabVet.Models.ExameAnalito;

interface

uses
  LabVet.Models.Base;

type
  TExameAnalito = class(TEntidadeAuditavel)
  public
    IdExameAnalito: Int64;
    IdExame: Int64;
    IdAnalito: Int64;
    constructor Create;
  end;

implementation

constructor TExameAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
