unit LabVet.Models.ModeloExameAnalito;

interface

uses
  LabVet.Models.Base;

type
  TModeloExameAnalito = class(TEntidadeAuditavel)
  public
    IdModeloExameAnalito: Int64;
    IdModeloExame: Int64;
    IdExameAnalito: Int64;
    DsSecao: string;
    NrExibicao: Integer;
    DsRotulo: string;
    DsTecnica: string;
    DsUnidadeMedida: string;
    DsReferencia: string;
    VrRefMinimo: TNumeroOpcional;
    VrRefMaximo: TNumeroOpcional;
    constructor Create;
  end;

implementation

constructor TModeloExameAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
