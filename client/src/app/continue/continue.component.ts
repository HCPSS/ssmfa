import { Component, OnInit } from '@angular/core';
import { environment } from '../../environments/environment'

@Component({
  selector: 'app-continue',
  templateUrl: './continue.component.html',
  styleUrls: ['./continue.component.scss']
})
export class ContinueComponent implements OnInit {

  constructor() { }

  ngOnInit() {
  }

  goHome() {
    window.location.href = environment.baseUrl
  }

}
