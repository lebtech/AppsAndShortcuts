using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace AppsAndShortcuts
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }



        private void Exit_Button_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Shutdown();
            // Environment.Exit(0) - Force closes the process
        }

        private void Window_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left)
                this.DragMove();
        }

        private void Device_Apps_Button_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Content = new Categories.DeviceApps();
        }

        private void User_Apps_Button_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Content = new Categories.UserApps();
        }

        private void Other_Apps_Button_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Content = new Categories.OtherApps();
        }

        private void Arc_Apps_Button_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Content = new Categories.ArcApps();
        }
    }
}
