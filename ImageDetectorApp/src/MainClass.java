import java.awt.LayoutManager;

import javax.swing.JFrame;
import javax.swing.UnsupportedLookAndFeelException;

public class MainClass extends JFrame  {
	private static final long serialVersionUID = 1L;
	public MainClass()
	{
		
	}

	public static void main(String[] args) {
       
		 try {
				javax.swing.UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");
			} catch (ClassNotFoundException e) {
				// 
				e.printStackTrace();
			} catch (InstantiationException e) {
				// 
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// 
				e.printStackTrace();
			} catch (UnsupportedLookAndFeelException e) {
				e.printStackTrace();
			}
		MainClass mainclass = new MainClass();
		PanelClass panelclass = new PanelClass();
		mainclass.add(panelclass);
		mainclass.setSize(650, 450);
		mainclass.setVisible(true);
		mainclass.setResizable(false);
		mainclass.setLocation(300, 100);
		mainclass.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
	}
}
