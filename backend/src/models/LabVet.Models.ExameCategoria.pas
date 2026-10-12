unit LabVet.Models.ExameCategoria;

interface

uses
  LabVet.Models.Base;

type
  TExameCategoria = class(TEntidadeAuditavel)
  public
    IdExameCategoria: Int64;
    NmCategoria: string;
  end;

implementation

end.
