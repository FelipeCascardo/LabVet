unit LabVet.Models.TipoAnimal;

interface

uses
  System.Generics.Collections,
  LabVet.Models.Base;

type
  TTipoAnimal = class(TEntidadeAuditavel)
  private
    FFilhos: TObjectList<TTipoAnimal>;
  public
    IdTipoAnimal: Int64;
    IdTipoAnimalPai: TInteiro64Opcional;
    NmTipoAnimal: string;
    DsDescricao: string;
    constructor Create;
    destructor Destroy; override;
    property Filhos: TObjectList<TTipoAnimal> read FFilhos;
  end;

implementation

constructor TTipoAnimal.Create;
begin
  inherited Create;
  StAtivo := True;
  FFilhos := TObjectList<TTipoAnimal>.Create(True);
end;

destructor TTipoAnimal.Destroy;
begin
  FFilhos.Free;
  inherited Destroy;
end;

end.
