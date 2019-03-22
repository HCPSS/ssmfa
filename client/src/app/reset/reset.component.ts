import { Component, OnInit } from '@angular/core';
import { AppComponent } from '../app.component'
import { ApiService } from '../api.service'
import { environment } from '../../environments/environment'

@Component({
  selector: 'app-reset',
  templateUrl: './reset.component.html',
  styleUrls: ['./reset.component.scss']
})
export class ResetComponent implements OnInit {
  recoveryEmail: String
  resetSent: boolean
  supportUrl: string

  constructor(
    private appComponent: AppComponent,
    private apiService: ApiService
  ) { }

  ngOnInit() {
    this.recoveryEmail = this.appComponent.recoveryEmail
    this.supportUrl = environment.supportUrl
  }

  startMFAReset(){
    this.apiService.postRequestMFASettingsReset()
    .subscribe(response => {
      if(response && response.success){
        this.resetSent = true
      }else{
        console.log("failed to postRequestMFASettingsReset")
      }
    })
  }

}
