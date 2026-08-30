import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ClosetService } from '../../services/closet';
import { Peca } from '../../models/peca.model';

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

  novaPeca: Peca = { nome: '', categoria: '', tamanho: '', preco: 0 };

  constructor(private closetService: ClosetService, private cdr: ChangeDetectorRef) {}

  ngOnInit(): void {
    this.buscarPecas();
  }

  buscarPecas(): void {
    this.carregando = true;
    this.erro = '';
    this.closetService.listarPecas().subscribe({
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

  cadastrarPeca(): void {
    if (!this.novaPeca.nome || !this.novaPeca.categoria) return;

    this.closetService.criarPeca(this.novaPeca).subscribe({
      next: (peca) => {
        this.pecas.push(peca);
        this.novaPeca = { nome: '', categoria: '', tamanho: '', preco: 0 };
        this.cdr.detectChanges();
      },
      error: () => {
        this.erro = 'Não foi possível cadastrar a peça. Verifique se você está logada.';
        this.cdr.detectChanges();
      }
    });
  }

  removerPeca(id: number | undefined): void {
    if (!id) return;
    this.closetService.removerPeca(id).subscribe({
      next: () => {
        this.pecas = this.pecas.filter(p => p.id !== id);
        this.cdr.detectChanges();
      },
      error: () => {
        this.erro = 'Não foi possível remover a peça. Verifique se você está logada.';
        this.cdr.detectChanges();
      }
    });
  }
}
