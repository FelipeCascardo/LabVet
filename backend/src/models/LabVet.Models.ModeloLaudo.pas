unit LabVet.Models.ModeloLaudo;

interface

uses
  LabVet.Models.Base;

type
  TModeloLaudo = class(TEntidadeAuditavel)
  public
    IdModeloLaudo: Int64;
    IdExame: TInteiro64Opcional;
    IdTipoAnimal: TInteiro64Opcional;
    CdModeloLaudo: string;
    NmModeloLaudo: string;
    DsFaixaIdade: string;
    NmArquivoOrigem: string;
    constructor Create;
  end;

implementation

constructor TModeloLaudo.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
