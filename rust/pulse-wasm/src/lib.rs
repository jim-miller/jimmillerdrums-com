use wasm_bindgen::prelude::*;
use web_sys::{HtmlElement, PointerEvent};

#[wasm_bindgen(start)]
pub fn main() {
    init_interactive_elements();
}

#[wasm_bindgen]
pub fn init_interactive_elements() {
    let window = web_sys::window().expect("no global window");
    let document = window.document().expect("should have a document");

    // Socials
    let links = document.query_selector_all(".social-link").unwrap();
    setup_toggle_logic(links, "is-active", 800);

    // YouTube Vids
    let videos = document.query_selector_all(".video-wrapper").unwrap();
    setup_toggle_logic(videos, "is-active", 1000);
}

fn setup_toggle_logic(elements: web_sys::NodeList, class_name: &'static str, delay_ms: i32) {
    for i in 0..elements.length() {
        let elem = elements.get(i).unwrap().dyn_into::<HtmlElement>().unwrap();
        let elem_down = elem.clone();
        let elem_up = elem.clone();

        let on_down = Closure::wrap(Box::new(move |_e: PointerEvent| {
            elem_down.class_list().add_1(class_name).unwrap();
        }) as Box<dyn FnMut(PointerEvent)>);

        let on_up = Closure::wrap(Box::new(move |_e: PointerEvent| {
            let el_inner = elem_up.clone();
            let window = web_sys::window().unwrap();
            
            // Allow transition time to complete on mobile taps
            let timeout_cb = Closure::once(move || {
                el_inner.class_list().remove_1(class_name).unwrap();
            });
            
            window.set_timeout_with_callback_and_timeout_and_arguments_0(
                timeout_cb.as_ref().unchecked_ref(),
                delay_ms
            ).unwrap();
            timeout_cb.forget();
        }) as Box<dyn FnMut(PointerEvent)>);

        elem.add_event_listener_with_callback("pointerdown", on_down.as_ref().unchecked_ref()).unwrap();
        elem.add_event_listener_with_callback("pointerup", on_up.as_ref().unchecked_ref()).unwrap();
        elem.add_event_listener_with_callback("pointercancel", on_up.as_ref().unchecked_ref()).unwrap();
        
        on_down.forget();
        on_up.forget();
    }
}
