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
    /// Interaction logic for OtherApps.xaml
    /// </summary>
    public partial class OtherApps : Page
    {
        public OtherApps()
        {
            InitializeComponent();
        }

        private void Problem_Tickets_Button_Click(object sender, RoutedEventArgs e)
        {
            OtherAppsFrame.Content = new OtherAppPages.ProblemTickets();
        }

        private void Change_Tickets_Button_Click(object sender, RoutedEventArgs e)
        {
            OtherAppsFrame.Content = new OtherAppPages.ChangeTickets();
        }

        private void Search_AD_Group_Button_Click(object sender, RoutedEventArgs e)
        {
            OtherAppsFrame.Content = new OtherAppPages.SearchAdGroup();
        }

        private void Find_Group_Members_Button_Click(object sender, RoutedEventArgs e)
        {
            OtherAppsFrame.Content = new OtherAppPages.FindGroupMembers();
        }
    }
}
