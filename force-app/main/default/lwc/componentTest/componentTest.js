import { LightningElement } from 'lwc';

export default class ComponentTest extends LightningElement {
    selectionHandler(e)
    {
        alert('Selected IDs'+ JSON.stringify(e.detail));
    }
}