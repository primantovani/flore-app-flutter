import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ClosetService } from '../../services/closet';
import { ToastService } from '../../services/toast';
import { Peca } from '../../models/peca.model';

type Ordenacao = 'nome' | 'preco-asc' | 'preco-desc' | 'status';

const PECA_VAZIA = (): Peca => ({ nome: '', categoria: '', tamanho: '', preco: 0 });

/// Gestão do closet circular da usuária logada (item 2 do app Flutter,
/// agora com paridade no dashboard): criar, editar, marcar vendida/
/// disponível e remover — com busca, filtro por categoria e ordenação
/// (mesmo padrão do Marketplace no Flutter).
@Component({
  selector: 'app-admin',
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.html',
  styleUrl: './admin.css'
})
export class Admin implements OnInit {
  pecas: Peca[] = [];
  carregando = true;
  erro = '';

  busca = '';
  categoriaFiltro = '';
  ordenacao: Ordenacao = 'nome';

  mostrarForm = false;
  itemEditando: Peca | null = null;
  form: Peca = PECA_VAZIA();
  salvando = false;

  itemParaRemover: Peca | null = null;

  constructor(private closetService: ClosetService, private toast: ToastService, private cdr: ChangeDetectorRef) {}

  ngOnInit(): void {
    this.buscarPecas();
  }

  buscarPecas(): void {
    this.carregando = true;
    this.erro = '';
    this.closetService.listarMinhas().subscribe({
      next: (dados) => {
        this.pecas = dados;
        this.carregando = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.erro = 'Não foi possível carregar as peças. O backend ainda pode não estar disponível.';
        this.carregando = false;
        this.cdr.detectChanges();
      }
    });
  }

  get categorias(): string[] {
    return [...new Set(this.pecas.map((p) => p.categoria))].sort();
  }

  get pecasFiltradas(): Peca[] {
    const termo = this.busca.trim().toLowerCase();
    let resultado = this.pecas.filter((p) => {
      const combinaBusca = termo === '' || p.nome.toLowerCase().includes(termo);
      const combinaCategoria = this.categoriaFiltro === '' || p.categoria === this.categoriaFiltro;
      return combinaBusca && combinaCategoria;
    });

    switch (this.ordenacao) {
      case 'preco-asc':
        resultado = [...resultado].sort((a, b) => a.preco - b.preco);
        break;
      case 'preco-desc':
        resultado = [...resultado].sort((a, b) => b.preco - a.preco);
        break;
      case 'status':
        resultado = [...resultado].sort((a, b) => (a.status ?? '').localeCompare(b.status ?? ''));
        break;
      default:
        resultado = [...resultado].sort((a, b) => a.nome.localeCompare(b.nome));
    }
    return resultado;
  }

  abrirCadastro(): void {
    this.itemEditando = null;
    this.form = PECA_VAZIA();
    this.mostrarForm = true;
  }

  abrirEdicao(peca: Peca): void {
    this.itemEditando = peca;
    this.form = { ...peca };
    this.mostrarForm = true;
  }

  cancelarForm(): void {
    this.mostrarForm = false;
    this.itemEditando = null;
  }

  salvar(): void {
    if (!this.form.nome || !this.form.categoria) return;

    this.salvando = true;
    const operacao = this.itemEditando?.id
      ? this.closetService.atualizarPeca(this.itemEditando.id, this.form)
      : this.closetService.criarPeca(this.form);

    operacao.subscribe({
      next: (peca) => {
        if (this.itemEditando) {
          this.pecas = this.pecas.map((p) => (p.id === peca.id ? peca : p));
          this.toast.sucesso('Peça atualizada com sucesso.');
        } else {
          this.pecas = [peca, ...this.pecas];
          this.toast.sucesso('Peça cadastrada com sucesso.');
        }
        this.salvando = false;
        this.mostrarForm = false;
        this.itemEditando = null;
        this.cdr.detectChanges();
      },
      error: () => {
        this.toast.erro('Não foi possível salvar a peça. Verifique se você está logada.');
        this.salvando = false;
        this.cdr.detectChanges();
      }
    });
  }

  alternarStatus(peca: Peca): void {
    if (!peca.id) return;
    const novoStatus = peca.status === 'sold' ? 'available' : 'sold';
    this.closetService.marcarStatus(peca.id, novoStatus).subscribe({
      next: (atualizada) => {
        this.pecas = this.pecas.map((p) => (p.id === atualizada.id ? atualizada : p));
        this.toast.sucesso(novoStatus === 'sold' ? 'Peça marcada como vendida.' : 'Peça marcada como disponível.');
        this.cdr.detectChanges();
      },
      error: () => {
        this.toast.erro('Não foi possível atualizar o status da peça.');
        this.cdr.detectChanges();
      }
    });
  }

  confirmarRemocao(peca: Peca): void {
    this.itemParaRemover = peca;
  }

  cancelarRemocao(): void {
    this.itemParaRemover = null;
  }

  removerConfirmado(): void {
    const peca = this.itemParaRemover;
    if (!peca?.id) return;

    this.closetService.removerPeca(peca.id).subscribe({
      next: () => {
        this.pecas = this.pecas.filter((p) => p.id !== peca.id);
        this.itemParaRemover = null;
        this.toast.sucesso('Peça removida.');
        this.cdr.detectChanges();
      },
      error: () => {
        this.toast.erro('Não foi possível remover a peça.');
        this.itemParaRemover = null;
        this.cdr.detectChanges();
      }
    });
  }
}
