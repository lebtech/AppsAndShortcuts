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

namespace AppsAndShortcuts.Categories
{
    /// <summary>
    /// Interaction logic for UserApps.xaml
    /// </summary>
    public partial class UserApps : Page
    {
        public UserApps()
        {
            InitializeComponent();
        }

        private void Find_AD_Groups_Button_Click(object sender, RoutedEventArgs e)
        {
            UserAppsFrame.Content = new UserAppPages.FindAdGroups();
        }

        private void Find_Assigned_Devices_Button_Click(object sender, RoutedEventArgs e)
        {
            UserAppsFrame.Content = new UserAppPages.FindAssignedDevices();
        }

        private void Find_Mail_Server_Button_Click(object sender, RoutedEventArgs e)
        {
            UserAppsFrame.Content = new UserAppPages.FindMailServer();
        }

        private void Find_RHICrypt_Password_Button_Click(object sender, RoutedEventArgs e)
        {
            UserAppsFrame.Content = new UserAppPages.FindCryptPassword();
        }

        private void Find_Software_Button_Click(object sender, RoutedEventArgs e)
        {
            UserAppsFrame.Content = new UserAppPages.FindSoftware();
        }
    }
}
