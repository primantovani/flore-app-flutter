export interface Peca {
  id?: number;
  nome: string;
  categoria: string;
  tamanho?: string;
  preco: number;
  status?: 'available' | 'sold';
  ownerName?: string;
}
