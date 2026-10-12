unit LabVet.Models.Analito;

interface

uses
  LabVet.Models.Base;

type
  TTipoValorAnalito = (
    tvaInteiro = 1,
    tvaDecimal = 2,
    tvaCaractere = 3,
    tvaMisto = 4
  );

  TAnalito = class(TEntidadeAuditavel)
  public
    IdAnalito: Int64;
    CdAnalito: string;
    NmAnalito: string;
    DsTecnica: string;
    DsUnidadeMedida: string;
    TpValor: TTipoValorAnalito;
    constructor Create;
  end;

implementation

constructor TAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
  TpValor := tvaCaractere;
end;

end.
