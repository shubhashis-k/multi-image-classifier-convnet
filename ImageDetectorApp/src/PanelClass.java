import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.FileFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.CopyOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;

import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.filechooser.FileNameExtensionFilter;

public class PanelClass extends JPanel {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String finalimageName="";

	private Icon image = new ImageIcon("Image/puppy.jpg");
	private JFileChooser fc = new JFileChooser();

	private JLabel imageLabel = new JLabel(image);
	private JLabel resultLabel = new JLabel("Results");
	private JLabel catLabel = new JLabel("Cat");
	private JLabel dogLabel = new JLabel("Dog");
	private JLabel catPercentage = new JLabel("xx%");
	private JLabel dogPercentage = new JLabel("yy%");

	private JButton loadButton = new JButton("Load Image");
	private JButton detectButton = new JButton("Detect !");

	Font font20 = new Font("Cambria", Font.ROMAN_BASELINE, 20);
	Font font30 = new Font("Cambria", Font.ROMAN_BASELINE, 30);

	private class TheHandler implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent event) {
			Object action = event.getSource();

			if (action == loadButton) {
				// activity of load button

				FileNameExtensionFilter filter = new FileNameExtensionFilter("JPEG file", "jpg", "jpeg","png");
				fc.setFileFilter(filter);
				int response = fc.showOpenDialog(null);
				try {
					if (response == JFileChooser.APPROVE_OPTION) {
						String pathName = fc.getSelectedFile().getPath();
						System.out.println(pathName);
						// JOptionPane.showMessageDialog(null, "Now Detect");
						// ImageIcon icon = new ImageIcon(pathName);
						ImageIcon icon = new ImageIcon(new ImageIcon(pathName).getImage()
								.getScaledInstance(imageLabel.getWidth(), imageLabel.getHeight(), Image.SCALE_FAST));
						imageLabel.setIcon(icon);

						Path FROM = Paths.get(pathName);
						String imageName = "";
						if (pathName.toLowerCase().contains("jpg")) {
							imageName = "a.jpg";
							finalimageName="a%jpg";
						} else if (pathName.toLowerCase().contains("png")) {
							imageName = "a.png";
							finalimageName="a%png";
						}

						Path TO = Paths.get("/home/torch/Desktop/images/" + imageName);

						CopyOption[] options = new CopyOption[] { StandardCopyOption.REPLACE_EXISTING,
								StandardCopyOption.COPY_ATTRIBUTES };

						Files.copy(FROM, TO, options);

					} else {
						JOptionPane.showMessageDialog(null, "Feel Free to Look Later");
					}
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			} else if (action == detectButton) {
				
				URL url;

		        try {
		            // get URL content

		            String a="http://localhost:8888/path/"+finalimageName;
		            url = new URL(a);
		            URLConnection conn = url.openConnection();

		            // open the stream and put it into BufferedReader
		            BufferedReader br = new BufferedReader(
		                               new InputStreamReader(conn.getInputStream()));

		            String inputLine;
		            ArrayList<String> arr =  new ArrayList<>();
		            while ((inputLine = br.readLine()) != null) {
		                    //System.out.println(inputLine);
		            	arr.add(inputLine);
		            }
		            br.close();
                    
		            attachToGui(arr);
		            

		        } catch (MalformedURLException e) {
		            e.printStackTrace();
		        } catch (IOException e) {
		            e.printStackTrace();
		        }

			}
		}

		private void attachToGui(ArrayList<String> arr) {
			float per=Float.parseFloat(arr.get(1));
			per = (per*100);
			
			catLabel.setText(arr.get(0));
			catPercentage.setText(String.format("%.2f", per)+"%");
			dogLabel.setText(arr.get(2));
			
			 per=Float.parseFloat(arr.get(3));
			 per = (per*100);
		       
			dogPercentage.setText(String.format("%.2f", per)+"%");
			
		}
	}

	public PanelClass() {
		TheHandler handler = new TheHandler();

		add(imageLabel);

		loadButton.setFont(font20);
		loadButton.addActionListener(handler);
		add(loadButton);

		resultLabel.setFont(font30);
		add(resultLabel);
		catLabel.setFont(font20);
		add(catLabel);
		catPercentage.setFont(font20);
		add(catPercentage);
		dogLabel.setFont(font20);
		add(dogLabel);
		dogPercentage.setFont(font20);
		add(dogPercentage);

		detectButton.setFont(font20);
		detectButton.addActionListener(handler);
		add(detectButton);
	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		imageLabel.setLocation(20, 20);
		loadButton.setLocation(105, 255);

		resultLabel.setLocation(430, 20);
		catLabel.setLocation(400, 80);
		catPercentage.setLocation(500, 80);
		dogLabel.setLocation(400, 110);
		dogPercentage.setLocation(500, 110);

		detectButton.setLocation(430, 255);
	}
}
