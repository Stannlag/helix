import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent) },
  { path: 'calendar', loadComponent: () => import('./features/calendar/calendar-view/calendar-view.component').then(m => m.CalendarViewComponent) },
  { path: 'activities', loadComponent: () => import('./features/activities/activity-form/activity-form.component').then(m => m.ActivityFormComponent) },
  { path: '', redirectTo: '/calendar', pathMatch: 'full' },
  { path: '**', redirectTo: '/calendar' } // Or a NotFoundComponent
];
