/*
* Copyright (c) 2017 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace Notejot {
    public class Application : Granite.Application {
        private List<MainWindow> open_notes = new List<MainWindow>();
        private NoteManager note_manager = new NoteManager();


        public Application () {
            Object (flags: ApplicationFlags.FLAGS_NONE,
            application_id: "com.github.lainsce.coin");
	    }

        construct {
            app_icon = "com.github.lainsce.notejot";
            exec_name = "com.github.lainsce.notejot";
            app_launcher = "com.github.lainsce.notejot";

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            add_accelerator ("<Control>q", "app.quit", null);
            quit_action.activate.connect (() => {
                List<Storage> storage = new List<Storage>();

    	        foreach (MainWindow windows in open_notes) {
    	            storage.append(windows.get_storage_note());
    	            windows.close();
    	        }

    	        note_manager.save_notes(storage);
            });

            var test_action = new SimpleAction ("test", null);
            add_action (test_action);
            add_accelerator ("<Control>h", "app.test", null);
            test_action.activate.connect (() => {
            	unowned List<Gtk.Window> windows = get_windows ();
            	windows.@foreach ((window) => {
            		var note = (MainWindow)window;
            		print (note.content + "\n");
            	});
            });
        }

        protected override void activate () {
    	    var list = note_manager.load_from_file();

            if (list.size == 0) {
                create_note(null);
            } else {
                foreach (Storage storage in list) {
                    create_note(storage);
                }
            }
	    }

	    public void create_note(Storage? storage) {
	        var note = new MainWindow(this, storage);
            note.get_storage_note();
	        open_notes.append(note);
	    }

	    public void remove_note(MainWindow note) {
	        open_notes.remove(note);
	    }

	    public void quit_note(MainWindow window) {
	        List<Storage> storage = new List<Storage>();

	        foreach (MainWindow w in open_notes) {
	            storage.append(w.get_storage_note());
                window.close();
	        }

	        note_manager.save_notes(storage);
	    }

        public static int main (string[] args) {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (Build.GETTEXT_PACKAGE);

            var app = new Application();
            return app.run(args);
        }
    }
}